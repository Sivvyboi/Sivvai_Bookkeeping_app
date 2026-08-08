import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/local_transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/size_config.dart';
import '../widgets/themed_dialogs.dart';

class GlobalHistoryScreen extends StatefulWidget {
  final num? scrollToTransactionId;

  const GlobalHistoryScreen({super.key, this.scrollToTransactionId});

  @override
  State<GlobalHistoryScreen> createState() => _GlobalHistoryScreenState();
}

class _GlobalHistoryScreenState extends State<GlobalHistoryScreen> {
  TransactionTypeFilter _typeFilter = TransactionTypeFilter.all;
  TransactionDateFilter _dateFilter = TransactionDateFilter.allTime;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    final dateFormat = DateFormat('MMM dd • hh:mm a');
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Seamless Custom Top Header ──────
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 8,
              left: 2.w,
              right: 4.w,
              bottom: 1.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (canPop)
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      )
                    else
                      SizedBox(width: 2.w),
                    Text(
                      'Global History',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<TransactionTypeFilter>(
                  initialValue: _typeFilter,
                  icon: Icon(Icons.filter_list, color: theme.colorScheme.primary),
                  onSelected: (filter) => setState(() => _typeFilter = filter),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: TransactionTypeFilter.all, child: Text('Show All')),
                    const PopupMenuItem(value: TransactionTypeFilter.sales, child: Text('Sales Only')),
                    const PopupMenuItem(value: TransactionTypeFilter.expenses, child: Text('Expenses Only')),
                    const PopupMenuItem(value: TransactionTypeFilter.debts, child: Text('Debts & Payments')),
                  ],
                ),
              ],
            ),
          ),

          // Tight row for the filter chips matching the ledger style spacing
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0.5.h, 4.w, 1.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildDateChip('All', TransactionDateFilter.allTime),
                  SizedBox(width: 2.w),
                  _buildDateChip('Today', TransactionDateFilter.today),
                  SizedBox(width: 2.w),
                  _buildDateChip('This Week', TransactionDateFilter.thisWeek),
                  SizedBox(width: 2.w),
                  _buildDateChip('This Month', TransactionDateFilter.thisMonth),
                ],
              ),
            ),
          ),

          // Main dynamic stream builder block
          Expanded(
            child: StreamBuilder<List<LocalTransaction>>(
              stream: provider.watchTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final now = DateTime.now();
                final transactions = (snapshot.data ?? []).where((tx) {
                  if (_dateFilter == TransactionDateFilter.today) {
                    if (tx.timestamp.year != now.year || tx.timestamp.month != now.month || tx.timestamp.day != now.day) return false;
                  } else if (_dateFilter == TransactionDateFilter.thisWeek) {
                    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                    final startNormalized = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
                    if (tx.timestamp.isBefore(startNormalized)) return false;
                  } else if (_dateFilter == TransactionDateFilter.thisMonth) {
                    if (tx.timestamp.year != now.year || tx.timestamp.month != now.month) return false;
                  }

                  if (_typeFilter == TransactionTypeFilter.sales) {
                    return tx.transactionType == 'INFLOW' && !tx.isCredit;
                  }
                  if (_typeFilter == TransactionTypeFilter.expenses) {
                    return tx.transactionType == 'OUTFLOW' && !tx.isCredit;
                  }
                  if (_typeFilter == TransactionTypeFilter.debts) {
                    return tx.isCredit || tx.transactionType == 'PAYMENT';
                  }
                  return true;
                }).toList();

                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 12.w, color: theme.dividerTheme.color),
                        SizedBox(height: 2.h),
                        Text('No matching records found.', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];

                    return _InteractiveTransactionCard(
                      tx: tx,
                      dateFormat: dateFormat,
                      statusColors: statusColors,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, TransactionDateFilter filter) {
    return ChoiceChip(
      label: Text(label),
      selected: _dateFilter == filter,
      onSelected: (_) => setState(() => _dateFilter = filter),
    );
  }
}

class _InteractiveTransactionCard extends StatelessWidget {
  final LocalTransaction tx;
  final DateFormat dateFormat;
  final StatusColors statusColors;

  const _InteractiveTransactionCard({
    required this.tx,
    required this.dateFormat,
    required this.statusColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    final isOutflow = tx.transactionType == 'OUTFLOW';
    final isPayment = tx.transactionType == 'PAYMENT';

    bool isCashOut = isOutflow;
    if (isPayment && tx.customer.value != null) {
      isCashOut = tx.customer.value!.relationType == 'CREDITOR';
    }

    Color amountColor = isCashOut ? statusColors.outflow! : statusColors.inflow!;
    if (tx.isCredit) amountColor = statusColors.debt!;

    String titleText = tx.remarks?.isNotEmpty == true
        ? tx.remarks!
        : (isPayment ? 'Debt Payment' : (isOutflow ? 'Expense' : 'Sale'));

    String metaSubtitle = dateFormat.format(tx.timestamp);
    if (tx.customer.value != null) {
      metaSubtitle = '${tx.customer.value!.fullName} • $metaSubtitle';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 1.5.h), // Matches your exact working dashboard spacing coefficient
      child: ListTile(
        onTap: () => _showContactStyleBottomSheet(context, provider, titleText, amountColor, isCashOut),
        leading: CircleAvatar(
          backgroundColor: amountColor.withValues(alpha: 0.1),
          child: Icon(isCashOut ? Icons.arrow_upward : Icons.arrow_downward, color: amountColor, size: 20),
        ),
        title: Text(titleText, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(metaSubtitle, style: TextStyle(fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                (isCashOut ? '- ' : '+ ') + SizeConfig.formatCompactCurrency(tx.amount),
                style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 15.sp)
            ),
            SizedBox(width: 2.w),
            Icon(Icons.chevron_right, size: 16.sp, color: theme.hintColor),
          ],
        ),
      ),
    );
  }

  void _showContactStyleBottomSheet(BuildContext context, TransactionProvider provider, String title, Color accentColor, bool isCashOut) {
    final theme = Theme.of(context);
    // Capture the parent screen context BEFORE showing the sheet.
    // The sheet's builder parameter shadows 'context' with a sheet-scoped
    // context that becomes invalid once the sheet is popped — using it after
    // Navigator.pop() causes the confirmation dialogs to silently fail.
    final pageContext = context;

    showModalBottomSheet(
      context: pageContext,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))
      ),
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 10.w,
                height: 4,
                margin: EdgeInsets.only(bottom: 2.h),
                decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))
            ),
            Text(
              title,
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
              decoration: BoxDecoration(color: accentColor.withValues(alpha: .1), borderRadius: BorderRadius.circular(20)),
              child: Text(
                'Amount: ${(isCashOut ? "- " : "+ ")}${SizeConfig.formatCompactCurrency(tx.amount)}',
                style: TextStyle(fontSize: 14.sp, color: accentColor, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 3.h),
            _buildOptionTile(
                sheetContext,
                Icons.edit_outlined,
                'Edit Transaction Details',
                theme.colorScheme.primary,
                    () {
                  Navigator.pop(sheetContext);
                  // Use the captured parent context — sheet context is dead after pop
                  _showEditDialog(pageContext, provider);
                }
            ),
            _buildOptionTile(
                sheetContext,
                Icons.delete_outline,
                'Delete Permanently',
                Colors.red,
                    () {
                  Navigator.pop(sheetContext);
                  // Use the captured parent context — sheet context is dead after pop
                  _showDeleteConfirmation(pageContext, provider);
                }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color)
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: theme.textTheme.bodyLarge?.color)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }

  void _showEditDialog(BuildContext context, TransactionProvider provider) {
    final amountController = TextEditingController(text: tx.amount.toString());
    final remarksController = TextEditingController(text: tx.remarks ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount (₦)', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(labelText: 'Remarks / Label', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newAmount = double.tryParse(amountController.text.trim());
              if (newAmount != null && newAmount > 0) {
                await provider.updateTransaction(
                  id: tx.id,
                  amount: newAmount,
                  type: tx.transactionType,
                  remarks: remarksController.text.trim(),
                  customer: tx.customer.value,
                  isCredit: tx.isCredit,
                );
                await provider.refreshData();
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, TransactionProvider provider) async {
    final confirmed = await ThemedDialogs.showDeleteConfirmation(
      context,
      itemType: 'transaction',
      detail: 'This recalculates your cash balances and cannot be undone.',
    );
    if (confirmed == true && context.mounted) {
      await provider.deleteTransaction(tx.id);
      await provider.refreshData();
      if (context.mounted) {
        ThemedDialogs.showSuccessSnackBar(context, 'Transaction deleted successfully.');
      }
    }
  }
}