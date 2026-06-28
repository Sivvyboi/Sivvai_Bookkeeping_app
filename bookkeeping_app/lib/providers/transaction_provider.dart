import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/local_customer.dart';
import '../models/local_transaction.dart';
import '../services/database_service.dart';

enum TransactionTypeFilter { all, sales, expenses, debts }

enum TransactionDateFilter { allTime, today, thisWeek, thisMonth }

/// TransactionProvider manages the application state for transactions and customers.
class TransactionProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<LocalTransaction> _allTransactions = [];
  List<LocalCustomer> _customers = [];

  // Filter State
  TransactionTypeFilter _typeFilter = TransactionTypeFilter.all;
  TransactionDateFilter _dateFilter = TransactionDateFilter.allTime;

  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<LocalTransaction>>? _transactionSubscription;
  StreamSubscription<List<LocalCustomer>>? _customerSubscription;

  TransactionProvider() {
    _initListeners();
  }

  // --- Getters ---

  List<LocalTransaction> get transactions {
    return _allTransactions.where((t) {
      if (_typeFilter == TransactionTypeFilter.sales) {
        return t.transactionType == 'INFLOW' && !t.isCredit;
      }
      if (_typeFilter == TransactionTypeFilter.expenses) {
        return t.transactionType == 'OUTFLOW' && !t.isCredit;
      }
      if (_typeFilter == TransactionTypeFilter.debts) {
        return t.isCredit || t.transactionType.startsWith('PAYMENT');
      }
      return true;
    }).toList();
  }

  List<LocalCustomer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TransactionTypeFilter get typeFilter => _typeFilter;
  TransactionDateFilter get dateFilter => _dateFilter;

  /// Expose direct streams for high-performance reactive UI binding
  Stream<List<LocalTransaction>> watchTransactions() =>
      _dbService.watchTransactions();
  Stream<List<LocalCustomer>> watchCustomers() => _dbService.watchCustomers();

  // Cached Aggregate State
  double _totalLiquidCash = 0.0;
  double _totalSales = 0.0;
  double _totalExpenses = 0.0;

  // --- Refactored Financial Logic (Strict Rules) ---

  double get totalLiquidCash => _totalLiquidCash;

  double get totalOwedToYou => _customers
      .where((c) => c.relationType == 'DEBTOR')
      .fold(0.0, (sum, c) => sum + c.totalDebtAmount);

  double get totalYouOwe => _customers
      .where((c) => c.relationType == 'CREDITOR')
      .fold(0.0, (sum, c) => sum + c.totalDebtAmount);

  List<LocalCustomer> get debtors => _customers
      .where((c) => c.relationType == 'DEBTOR' && c.totalDebtAmount != 0)
      .toList();
  List<LocalCustomer> get creditors => _customers
      .where((c) => c.relationType == 'CREDITOR' && c.totalDebtAmount != 0)
      .toList();

  // Legacy compatibility for Dashboard
  double get cashBalance => totalLiquidCash;
  double get totalSales => _totalSales;
  double get totalExpenses => _totalExpenses;
  double get totalDebts => totalOwedToYou;

  // --- Filter Actions ---

  void setTypeFilter(TransactionTypeFilter filter) {
    _typeFilter = filter;
    notifyListeners();
  }

  void setDateFilter(TransactionDateFilter filter) {
    _dateFilter = filter;
    _updateTransactionStream();
  }

  Future<void> refreshData() async {
    _updateTransactionStream();
  }

  // --- Initialization & Stream Management ---

  void _initListeners() {
    _updateTransactionStream();

    _customerSubscription = _dbService.watchCustomers().listen((data) {
      _customers = data;
      notifyListeners();
    });
  }

  void _updateTransactionStream() {
    _transactionSubscription?.cancel();

    DateTime? start;
    final now = DateTime.now();

    if (_dateFilter == TransactionDateFilter.today) {
      start = DateTime(now.year, now.month, now.day);
    } else if (_dateFilter == TransactionDateFilter.thisWeek) {
      start = now.subtract(Duration(days: now.weekday - 1));
      start = DateTime(start.year, start.month, start.day);
    } else if (_dateFilter == TransactionDateFilter.thisMonth) {
      start = DateTime(now.year, now.month, 1);
    }

    _transactionSubscription = _dbService
        .watchTransactions(start: start)
        .listen((data) {
          _allTransactions = data;
          _calculateAggregatesAsync().then((_) {
            notifyListeners();
          });
        });
  }

  Future<void> _calculateAggregatesAsync() async {
    final isar = DatabaseService.isar;

    final sales = await isar.localTransactions
        .filter()
        .transactionTypeEqualTo('INFLOW')
        .amountProperty()
        .sum();
    final expenses = await isar.localTransactions
        .filter()
        .transactionTypeEqualTo('OUTFLOW')
        .amountProperty()
        .sum();

    final cashInflows = await isar.localTransactions
        .filter()
        .transactionTypeEqualTo('INFLOW')
        .isCreditEqualTo(false)
        .amountProperty()
        .sum();
    final cashOutflows = await isar.localTransactions
        .filter()
        .transactionTypeEqualTo('OUTFLOW')
        .isCreditEqualTo(false)
        .amountProperty()
        .sum();

    final payments = await isar.localTransactions
        .filter()
        .transactionTypeStartsWith('PAYMENT')
        .findAll();
    double paymentsReceived = 0.0;
    double paymentsPaid = 0.0;

    for (var p in payments) {
      if (p.transactionType == 'PAYMENT_IN') {
        paymentsReceived += p.amount;
      } else if (p.transactionType == 'PAYMENT_OUT') {
        paymentsPaid += p.amount;
      } else {
        // Fallback for unmigrated
        await p.customer.load();
        if (p.customer.value == null ||
            p.customer.value!.relationType == 'DEBTOR') {
          paymentsReceived += p.amount;
        } else {
          paymentsPaid += p.amount;
        }
      }
    }

    _totalSales = sales;
    _totalExpenses = expenses;
    _totalLiquidCash =
        (cashInflows + paymentsReceived) - (cashOutflows + paymentsPaid);
  }

  // --- Database Actions ---

  Future<void> saveQuickTransaction({
    required double amount,
    required String type,
    String? remarks,
    LocalCustomer? customer,
    bool isCredit = false,
  }) async {
    if (amount <= 0) {
      _errorMessage = "Please enter a valid amount greater than zero.";
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      await _dbService.addTransaction(
        amount: amount,
        transactionType: type,
        remarks: remarks,
        customer: customer,
        timestamp: DateTime.now(),
        isCredit: isCredit,
      );
    } catch (e) {
      _errorMessage = "Failed to save transaction: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> settleLedgerBalance({
    required int customerId,
    required double amountPaid,
    required bool isCreditor,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _dbService.settleLedgerBalance(
        customerId: customerId,
        amountPaid: amountPaid,
        isCreditor: isCreditor,
      );
    } catch (e) {
      _errorMessage = "Settlement failed: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTransaction({
    required int id,
    required double amount,
    required String type,
    String? remarks,
    LocalCustomer? customer,
    bool isCredit = false,
  }) async {
    _setLoading(true);
    try {
      await _dbService.updateTransaction(
        id: id,
        amount: amount,
        transactionType: type,
        remarks: remarks,
        customer: customer,
        isCredit: isCredit,
      );
    } catch (e) {
      _errorMessage = "Update failed: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTransaction(int id) async {
    _setLoading(true);
    try {
      await _dbService.deleteTransaction(id);
    } catch (e) {
      _errorMessage = "Delete failed: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  Future<LocalCustomer?> addCustomer(
    String name, {
    String? phone,
    required String relationType,
  }) async {
    _setLoading(true);
    try {
      return await _dbService.addCustomer(
        name,
        phone: phone,
        relationType: relationType,
      );
    } catch (e) {
      _errorMessage = "Failed to add customer: ${e.toString()}";
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCustomer(LocalCustomer customer) async {
    _setLoading(true);
    try {
      await _dbService.updateCustomer(customer);
    } catch (e) {
      _errorMessage = "Update customer failed: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCustomer(int id) async {
    _setLoading(true);
    try {
      await _dbService.deleteCustomer(id);
    } catch (e) {
      _errorMessage = "Delete customer failed: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> exportData() async {
    _setLoading(true);
    try {
      final filePath = await _dbService.exportBackup();
      await Share.shareXFiles([XFile(filePath)], text: 'Bookkeeper App Backup');
      return true;
    } catch (e) {
      _errorMessage = "Export failed: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> importData() async {
    _setLoading(true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        await _dbService.importBackup(jsonString);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = "Import failed: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAllData() async {
    _setLoading(true);
    try {
      await _dbService.clearAllData();
      return true;
    } catch (e) {
      _errorMessage = "Delete failed: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    _customerSubscription?.cancel();
    super.dispose();
  }
}
