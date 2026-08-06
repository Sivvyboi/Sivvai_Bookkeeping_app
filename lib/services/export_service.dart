import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' hide Border;
import 'package:share_plus/share_plus.dart';
import '../models/local_customer.dart';
import '../models/local_transaction.dart';

class ExportService {
  ExportService._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _fileDateFormat = DateFormat('yyyyMMdd_HHmm');
  static final NumberFormat _currencyFormat = NumberFormat.currency(symbol: 'NGN ', decimalDigits: 2);

  /// Filters transactions by date range if provided.
  static List<LocalTransaction> filterTransactions(
    List<LocalTransaction> transactions,
    DateTimeRange? dateRange,
  ) {
    if (dateRange == null) return transactions;
    final start = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day, 0, 0, 0);
    final end = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day, 23, 59, 59);

    return transactions.where((tx) {
      return tx.timestamp.isAfter(start.subtract(const Duration(seconds: 1))) &&
          tx.timestamp.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
  }

  /// Helper to get explicit human-readable status mode for a transaction.
  static String getStatusMode(LocalTransaction tx) {
    if (tx.isCredit) {
      return tx.transactionType == 'OUTFLOW'
          ? 'Pending Credit (Payable)'
          : 'Pending Debt (Receivable)';
    }
    if (tx.transactionType == 'INFLOW') return 'Cash Sale';
    if (tx.transactionType == 'OUTFLOW') return 'Cash Expense';
    if (tx.transactionType == 'PAYMENT_IN') return 'Payment Received';
    if (tx.transactionType == 'PAYMENT_OUT') return 'Payment Paid';
    return tx.transactionType;
  }

  /// Exports financial report according to [exportFormat] ('pdf', 'excel', or 'both')
  /// and opens the native OS share sheet.
  ///
  /// [customers] is used to compute Pending Ledger totals from each contact's
  /// pre-calculated net outstanding balance — NOT from raw transaction rows.
  static Future<bool> exportAndShare({
    required List<LocalTransaction> transactions,
    required List<LocalCustomer> customers,
    required String profileName,
    DateTimeRange? dateRange,
    required String exportFormat, // 'pdf', 'excel', or 'both'
  }) async {
    try {
      final filtered = filterTransactions(transactions, dateRange);
      final tempDir = await getTemporaryDirectory();
      final dateStamp = _fileDateFormat.format(DateTime.now());
      final safeProfileName = profileName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

      final List<XFile> filesToShare = [];

      if (exportFormat == 'pdf' || exportFormat == 'both') {
        final pdfFile = await _generatePdfFile(filtered, customers, profileName, dateRange, tempDir, safeProfileName, dateStamp);
        filesToShare.add(XFile(pdfFile.path));
      }

      if (exportFormat == 'excel' || exportFormat == 'both') {
        final excelFile = await _generateExcelFile(filtered, customers, profileName, dateRange, tempDir, safeProfileName, dateStamp);
        filesToShare.add(XFile(excelFile.path));
      }

      if (filesToShare.isNotEmpty) {
        await Share.shareXFiles(
          filesToShare,
          text: 'Sivvai Bookkeeper Report - $profileName',
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }

  // ── PDF Generation ────────────────────────────────────────────────────────

  static Future<File> _generatePdfFile(
    List<LocalTransaction> transactions,
    List<LocalCustomer> customers,
    String profileName,
    DateTimeRange? dateRange,
    Directory tempDir,
    String safeProfileName,
    String dateStamp,
  ) async {
    final pdf = pw.Document();

    // ── Cash Flow: calculated from non-credit transaction rows ─────────────
    double actualCashIn = 0;
    double actualCashOut = 0;

    for (var tx in transactions) {
      if (!tx.isCredit) {
        if (tx.transactionType == 'INFLOW' || tx.transactionType == 'PAYMENT_IN') {
          actualCashIn += tx.amount;
        } else if (tx.transactionType == 'OUTFLOW' || tx.transactionType == 'PAYMENT_OUT') {
          actualCashOut += tx.amount;
        }
      }
    }

    final netCashBalance = actualCashIn - actualCashOut;

    // ── Pending Ledger: derived from contact net balances ─────────────────
    // Contacts with totalDebtAmount == 0 are fully settled and excluded.
    final activeDebtors = customers
        .where((c) => c.relationType == 'DEBTOR' && c.totalDebtAmount > 0)
        .toList();
    final activeCreditors = customers
        .where((c) => c.relationType == 'CREDITOR' && c.totalDebtAmount > 0)
        .toList();

    final totalReceivables = activeDebtors.fold(0.0, (s, c) => s + c.totalDebtAmount);
    final totalPayables = activeCreditors.fold(0.0, (s, c) => s + c.totalDebtAmount);

    final dateRangeText = dateRange != null
        ? '${DateFormat('MMM dd, yyyy').format(dateRange.start)} – ${DateFormat('MMM dd, yyyy').format(dateRange.end)}'
        : 'All Time';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            // ── Header ───────────────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('10B981'),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SIVVAI BOOKKEEPER',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Financial Statement  •  Profile: $profileName',
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date Range:', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                      pw.Text(
                        dateRangeText,
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 11, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // ── Section 1: Net Cash Flow Summary ─────────────────────────
            pw.Text(
              'Net Cash Flow (Liquid Balance)',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('0F172A')),
            ),
            pw.SizedBox(height: 6),
            pw.Row(
              children: [
                _buildPdfMetricCard('Actual Cash In', _currencyFormat.format(actualCashIn), PdfColor.fromHex('10B981')),
                pw.SizedBox(width: 10),
                _buildPdfMetricCard('Actual Cash Out', _currencyFormat.format(actualCashOut), PdfColor.fromHex('EF4444')),
                pw.SizedBox(width: 10),
                _buildPdfMetricCard('Net Cash Balance', _currencyFormat.format(netCashBalance), PdfColor.fromHex('06B6D4')),
              ],
            ),

            pw.SizedBox(height: 20),

            // ── Section 2: Full Transaction Log ──────────────────────────
            pw.Text(
              'Transaction Log (${transactions.length} entries)',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            if (transactions.isEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 20),
                child: pw.Center(child: pw.Text('No transactions found for the selected period.')),
              )
            else
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('0F172A')),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.2),
                  1: const pw.FlexColumnWidth(3.0),
                  2: const pw.FlexColumnWidth(1.8),
                  3: const pw.FlexColumnWidth(2.5),
                  4: const pw.FlexColumnWidth(2.2),
                },
                headers: ['Date & Time', 'Contact / Description', 'Type', 'Mode / Status', 'Amount'],
                data: transactions.map((tx) {
                  final customerName = tx.customer.value?.fullName ?? '';
                  final desc = tx.remarks?.isNotEmpty == true
                      ? (customerName.isNotEmpty ? '$customerName – ${tx.remarks}' : tx.remarks!)
                      : (customerName.isNotEmpty ? customerName : 'General');
                  return [
                    _dateFormat.format(tx.timestamp),
                    desc,
                    tx.transactionType,
                    getStatusMode(tx),
                    _currencyFormat.format(tx.amount),
                  ];
                }).toList(),
              ),

            pw.SizedBox(height: 24),

            // ── Section 3: Active Pending Ledger (below transaction log) ──
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('FFFBEB'),
                border: pw.Border.all(color: PdfColor.fromHex('F59E0B'), width: 1.5),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Active Pending Ledger',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('92400E'),
                    ),
                  ),
                  pw.Text(
                    'Contacts with non-zero outstanding balances only. Fully settled accounts are excluded.',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 10),

                  // Pending totals summary cards
                  pw.Row(
                    children: [
                      _buildPdfMetricCard('Total Receivables (Owed to You)', _currencyFormat.format(totalReceivables), PdfColor.fromHex('F59E0B')),
                      pw.SizedBox(width: 10),
                      _buildPdfMetricCard('Total Payables (You Owe)', _currencyFormat.format(totalPayables), PdfColor.fromHex('6366F1')),
                    ],
                  ),

                  pw.SizedBox(height: 12),

                  // One row per active contact
                  if (activeDebtors.isEmpty && activeCreditors.isEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8),
                      child: pw.Center(
                        child: pw.Text(
                          'No outstanding balances. All accounts are fully settled.',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                      ),
                    )
                  else
                    pw.TableHelper.fromTextArray(
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('92400E')),
                      cellStyle: const pw.TextStyle(fontSize: 9),
                      cellAlignment: pw.Alignment.centerLeft,
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3.5),
                        1: const pw.FlexColumnWidth(2.5),
                        2: const pw.FlexColumnWidth(3.0),
                      },
                      headers: ['Contact Name', 'Status', 'Net Outstanding Amount'],
                      data: [
                        ...activeDebtors.map((c) => [
                          c.fullName,
                          'Receivable (Owed to You)',
                          _currencyFormat.format(c.totalDebtAmount),
                        ]),
                        ...activeCreditors.map((c) => [
                          c.fullName,
                          'Payable (You Owe)',
                          _currencyFormat.format(c.totalDebtAmount),
                        ]),
                      ],
                    ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    final file = File('${tempDir.path}/report_${safeProfileName}_$dateStamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildPdfMetricCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1.5),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            pw.SizedBox(height: 3),
            pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ── Excel Generation ──────────────────────────────────────────────────────

  static Future<File> _generateExcelFile(
    List<LocalTransaction> transactions,
    List<LocalCustomer> customers,
    String profileName,
    DateTimeRange? dateRange,
    Directory tempDir,
    String safeProfileName,
    String dateStamp,
  ) async {
    final excel = Excel.createExcel();

    // ── Sheet 1: Cash Flow Statement ──────────────────────────────────────
    final Sheet cashSheet = excel['Cash Flow Statement'];
    excel.setDefaultSheet('Cash Flow Statement');

    cashSheet.appendRow([
      TextCellValue('Date & Time'),
      TextCellValue('Type'),
      TextCellValue('Status / Mode'),
      TextCellValue('Contact Name'),
      TextCellValue('Remarks / Label'),
      TextCellValue('Amount (NGN)'),
    ]);

    double actualCashIn = 0;
    double actualCashOut = 0;

    final cashTransactions = transactions.where((tx) => !tx.isCredit).toList();
    for (var tx in cashTransactions) {
      if (tx.transactionType == 'INFLOW' || tx.transactionType == 'PAYMENT_IN') {
        actualCashIn += tx.amount;
      } else if (tx.transactionType == 'OUTFLOW' || tx.transactionType == 'PAYMENT_OUT') {
        actualCashOut += tx.amount;
      }

      final customerName = tx.customer.value?.fullName ?? '';
      cashSheet.appendRow([
        TextCellValue(_dateFormat.format(tx.timestamp)),
        TextCellValue(tx.transactionType),
        TextCellValue(getStatusMode(tx)),
        TextCellValue(customerName),
        TextCellValue(tx.remarks ?? ''),
        DoubleCellValue(tx.amount),
      ]);
    }

    cashSheet.appendRow([TextCellValue('')]);
    cashSheet.appendRow([
      TextCellValue('CASH FLOW SUMMARY'),
      TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue(''),
    ]);
    cashSheet.appendRow([
      TextCellValue('Actual Cash In'),
      TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue(''),
      DoubleCellValue(actualCashIn),
    ]);
    cashSheet.appendRow([
      TextCellValue('Actual Cash Out'),
      TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue(''),
      DoubleCellValue(actualCashOut),
    ]);
    cashSheet.appendRow([
      TextCellValue('Net Cash Balance'),
      TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue(''),
      DoubleCellValue(actualCashIn - actualCashOut),
    ]);

    // ── Sheet 2: Active Pending Ledger ────────────────────────────────────
    // Derived from each contact's pre-calculated net outstanding balance.
    // Contacts with totalDebtAmount == 0 are fully settled and excluded.
    final Sheet debtSheet = excel['Active Pending Ledger'];

    debtSheet.appendRow([
      TextCellValue('Contact Name'),
      TextCellValue('Status'),
      TextCellValue('Net Outstanding Amount (NGN)'),
    ]);

    final activeDebtors = customers
        .where((c) => c.relationType == 'DEBTOR' && c.totalDebtAmount > 0)
        .toList();
    final activeCreditors = customers
        .where((c) => c.relationType == 'CREDITOR' && c.totalDebtAmount > 0)
        .toList();

    for (final c in activeDebtors) {
      debtSheet.appendRow([
        TextCellValue(c.fullName),
        TextCellValue('Receivable (Owed to You)'),
        DoubleCellValue(c.totalDebtAmount),
      ]);
    }

    for (final c in activeCreditors) {
      debtSheet.appendRow([
        TextCellValue(c.fullName),
        TextCellValue('Payable (You Owe)'),
        DoubleCellValue(c.totalDebtAmount),
      ]);
    }

    if (activeDebtors.isEmpty && activeCreditors.isEmpty) {
      debtSheet.appendRow([
        TextCellValue('No outstanding balances — all accounts are fully settled.'),
        TextCellValue(''),
        TextCellValue(''),
      ]);
    }

    final totalReceivables = activeDebtors.fold(0.0, (s, c) => s + c.totalDebtAmount);
    final totalPayables = activeCreditors.fold(0.0, (s, c) => s + c.totalDebtAmount);

    debtSheet.appendRow([TextCellValue('')]);
    debtSheet.appendRow([
      TextCellValue('PENDING LEDGER SUMMARY'),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    debtSheet.appendRow([
      TextCellValue('Total Receivables (Owed to You)'),
      TextCellValue(''),
      DoubleCellValue(totalReceivables),
    ]);
    debtSheet.appendRow([
      TextCellValue('Total Payables (You Owe)'),
      TextCellValue(''),
      DoubleCellValue(totalPayables),
    ]);

    // Remove default empty Sheet1 if present
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final bytes = excel.save();
    final file = File('${tempDir.path}/report_${safeProfileName}_$dateStamp.xlsx');
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    return file;
  }
}