import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/local_customer.dart';
import '../models/local_transaction.dart';


class DatabaseService {
  static late Isar isar;

  // Private constructor for singleton
  DatabaseService._();

  static final DatabaseService _instance = DatabaseService._();

  factory DatabaseService() {
    return _instance;
  }

  /// 1. Initialize Isar and open the collections safely on app launch.
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [LocalCustomerSchema, LocalTransactionSchema],
      directory: dir.path,
    );

    // MIGRATION: Convert old 'PAYMENT' to 'PAYMENT_IN' or 'PAYMENT_OUT'
    final legacyPayments = await isar.localTransactions.filter().transactionTypeEqualTo('PAYMENT').findAll();
    if (legacyPayments.isNotEmpty) {
      await isar.writeTxn(() async {
        for (var p in legacyPayments) {
          await p.customer.load();
          if (p.customer.value == null || p.customer.value!.relationType == 'DEBTOR') {
            p.transactionType = 'PAYMENT_IN';
          } else {
            p.transactionType = 'PAYMENT_OUT';
          }
          await isar.localTransactions.put(p);
        }
      });
    }
  }

  /// 2. Insert a new 'LocalTransaction' safely and instantly
  Future<void> addTransaction({
    required double amount,
    DateTime? timestamp,
    String transactionType = 'INFLOW',
    String? remarks,
    LocalCustomer? customer,
    bool isCredit = false,
  }) async {
    final now = timestamp ?? DateTime.now();
    final newTransaction = LocalTransaction()
      ..amount = amount
      ..timestamp = now
      ..transactionType = transactionType
      ..remarks = remarks
      ..isCredit = isCredit;

    await isar.writeTxn(() async {
      // 1. If customer exists, make sure they are written first to hold a concrete ID
      if (customer != null) {
        customer.lastUsed = now;
        await isar.localCustomers.put(customer); // Forces ID assignment if new
        newTransaction.customer.value = customer; // Link it safely inside transaction
      }

      // 2. Save the transaction
      await isar.localTransactions.put(newTransaction);

      // 3. Save the relationship link context cleanly
      if (customer != null) {
        await newTransaction.customer.save();

        // 4. Optimization: Run math asynchronously or inline without choking the main flow
        await _recalculateCustomerDebt(customer.id);
      }
    });
  }

  /// Update an existing transaction
  Future<void> updateTransaction({
    required int id,
    required double amount,
    required String transactionType,
    String? remarks,
    LocalCustomer? customer,
    bool isCredit = false,
    DateTime? timestamp,
  }) async {
    final tx = await isar.localTransactions.get(id);
    if (tx == null) return;

    await tx.customer.load();
    final oldCustomer = tx.customer.value;
    final now = timestamp ?? DateTime.now();

    tx.amount = amount;
    tx.transactionType = transactionType;
    tx.remarks = remarks;
    tx.isCredit = isCredit;
    tx.timestamp = now;
    tx.customer.value = customer;

    await isar.writeTxn(() async {
      await isar.localTransactions.put(tx);
      await tx.customer.save();

      if (customer != null) {
        customer.lastUsed = now;
        await isar.localCustomers.put(customer);
      }

      if (oldCustomer != null) {
        await _recalculateCustomerDebt(oldCustomer.id);
      }
      if (customer != null && (oldCustomer == null || customer.id != oldCustomer.id)) {
        await _recalculateCustomerDebt(customer.id);
      }
    });
  }

  /// Delete a transaction
  Future<void> deleteTransaction(int id) async {
    final tx = await isar.localTransactions.get(id);
    if (tx == null) return;

    await tx.customer.load();
    final customer = tx.customer.value;

    await isar.writeTxn(() async {
      await isar.localTransactions.delete(id);
      if (customer != null) {
        await _recalculateCustomerDebt(customer.id);
      }
    });
  }

  Future<void> _recalculateCustomerDebt(int customerId) async {
    final customer = await isar.localCustomers.get(customerId);
    if (customer == null) return;

    final baseQuery = isar.localTransactions.filter().customer((q) => q.idEqualTo(customerId));

    final creditInflows = await baseQuery.transactionTypeEqualTo('INFLOW').isCreditEqualTo(true).amountProperty().sum();
    final creditOutflows = await baseQuery.transactionTypeEqualTo('OUTFLOW').isCreditEqualTo(true).amountProperty().sum();
    final paymentsIn = await baseQuery.transactionTypeEqualTo('PAYMENT_IN').amountProperty().sum();
    final paymentsOut = await baseQuery.transactionTypeEqualTo('PAYMENT_OUT').amountProperty().sum();

    // A positive balance means the contact owes us money overall.
    // INFLOW on credit increases how much they owe us (+ balance)
    // OUTFLOW on credit increases how much we owe them (- balance)
    double balance = creditInflows - creditOutflows;

    // Payments FROM them (PAYMENT_IN) reduce how much they owe us (- balance)
    // Payments TO them (PAYMENT_OUT) reduce how much we owe them (+ balance)
    balance -= paymentsIn;
    balance += paymentsOut;

    // Dynamically update their relationType if they cross the zero threshold to the other side
    if (balance >= 0) {
      customer.relationType = 'DEBTOR';
      customer.totalDebtAmount = balance;
    } else {
      customer.relationType = 'CREDITOR';
      customer.totalDebtAmount = -balance;
    }

    await isar.localCustomers.put(customer);
  }

  /// 3. Read transactions as a live stream
  Stream<List<LocalTransaction>> watchTransactions({DateTime? start, DateTime? end}) {
    final query = isar.localTransactions.where();

    if (start != null && end != null) {
      return query.filter().timestampBetween(start, end).sortByTimestampDesc().watch(fireImmediately: true);
    } else if (start != null) {
      return query.filter().timestampGreaterThan(start, include: true).sortByTimestampDesc().watch(fireImmediately: true);
    } else if (end != null) {
      return query.filter().timestampLessThan(end, include: true).sortByTimestampDesc().watch(fireImmediately: true);
    }

    return query.sortByTimestampDesc().watch(fireImmediately: true);
  }

  /// 4. Add a new 'LocalCustomer'
  Future<LocalCustomer> addCustomer(String name, {String? phone, required String relationType}) async {
    final newCustomer = LocalCustomer()
      ..fullName = name
      ..phoneNumber = phone
      ..relationType = relationType
      ..lastUsed = DateTime.now();

    await isar.writeTxn(() async {
      await isar.localCustomers.put(newCustomer);
    });

    return newCustomer;
  }

  /// Update an existing customer profile details
  Future<void> updateCustomer(LocalCustomer customer) async {
    await isar.writeTxn(() async {
      await isar.localCustomers.put(customer);
    });
  }

  /// Delete a customer profile by ID
  Future<void> deleteCustomer(int id) async {
    await isar.writeTxn(() async {
      await isar.localCustomers.delete(id);
    });
  }

  /// Settle a ledger balance by creating a non-credit transaction record.
  Future<void> settleLedgerBalance({
    required int customerId,
    required double amountPaid,
    required bool isCreditor,
  }) async {
    final customer = await isar.localCustomers.get(customerId);
    if (customer == null) return;

    final now = DateTime.now();
    final newTransaction = LocalTransaction()
      ..amount = amountPaid
      ..timestamp = now
      // Use directional payment types for settlements to distinguish from sales/expenses
      ..transactionType = isCreditor ? 'PAYMENT_OUT' : 'PAYMENT_IN'
      ..remarks = isCreditor ? 'Paid to Creditor' : 'Received from Debtor'
      ..isCredit = false;

    newTransaction.customer.value = customer;
    customer.lastUsed = now;

    await isar.writeTxn(() async {
      await isar.localTransactions.put(newTransaction);
      await newTransaction.customer.save();
      await isar.localCustomers.put(customer);
      await _recalculateCustomerDebt(customerId);
    });
  }

  /// 4b. Fetch the list of existing customers.
  Future<List<LocalCustomer>> getCustomers() async {
    return await isar.localCustomers.where().sortByLastUsedDesc().findAll();
  }

  /// 4c. Watch customers for real-time updates.
  Stream<List<LocalCustomer>> watchCustomers() {
    return isar.localCustomers.where().sortByLastUsedDesc().watch(fireImmediately: true);
  }

  /// 4d. Watch transactions for a specific customer
  Stream<List<LocalTransaction>> watchCustomerTransactions(int customerId) {
    return isar.localTransactions
        .filter()
        .customer((q) => q.idEqualTo(customerId))
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  /// 5. Export Data to JSON
  Future<String> exportBackup() async {
    final customers = await isar.localCustomers.where().findAll();
    final transactions = await isar.localTransactions.where().findAll();

    final transactionDataList = [];
    for (var t in transactions) {
      await t.customer.load();
      transactionDataList.add({
        'amount': t.amount,
        'timestamp': t.timestamp.toIso8601String(),
        'transactionType': t.transactionType,
        'remarks': t.remarks ?? "",
        'isCredit': t.isCredit,
        'customerName': t.customer.value?.fullName,
      });
    }

    final data = {
      'version': 5,
      'exportedAt': DateTime.now().toIso8601String(),
      'customers': customers.map((c) => {
        'fullName': c.fullName,
        'phoneNumber': c.phoneNumber ?? "",
        'totalDebtAmount': c.totalDebtAmount,
        'relationType': c.relationType,
        'lastUsed': c.lastUsed?.toIso8601String(),
      }).toList(),
      'transactions': transactionDataList,
    };

    final jsonString = jsonEncode(data);
    final directory = await getTemporaryDirectory();
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final file = File('${directory.path}/bookkeeper_backup_$dateStr.json');
    await file.writeAsString(jsonString);
    return file.path;
  }

  /// 6. Import Data from JSON string
  Future<void> importBackup(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString.trim());

    await isar.writeTxn(() async {
      await isar.localTransactions.clear();
      await isar.localCustomers.clear();

      final Map<String, LocalCustomer> nameToCustomer = {};

      final customersData = data['customers'] as List;
      for (var cData in customersData) {
        final customer = LocalCustomer()
          ..fullName = cData['fullName']
          ..phoneNumber = cData['phoneNumber']
          ..totalDebtAmount = (cData['totalDebtAmount'] as num).toDouble()
          ..relationType = cData['relationType'] ?? 'DEBTOR'
          ..lastUsed = cData['lastUsed'] != null ? DateTime.parse(cData['lastUsed']) : null;

        await isar.localCustomers.put(customer);
        nameToCustomer[customer.fullName] = customer;
      }

      final transactionsData = data['transactions'] as List;
      for (var tData in transactionsData) {
        final transaction = LocalTransaction()
          ..amount = (tData['amount'] as num).toDouble()
          ..timestamp = DateTime.parse(tData['timestamp'])
          ..transactionType = tData['transactionType']
          ..remarks = tData['remarks']
          ..isCredit = tData['isCredit'] ?? false;

        final customerName = tData['customerName'];
        if (customerName != null && nameToCustomer.containsKey(customerName)) {
          transaction.customer.value = nameToCustomer[customerName];
        }

        await isar.localTransactions.put(transaction);
        if (transaction.customer.value != null) {
          await transaction.customer.save();
        }
      }
    });
  }

  /// 7. Clear All Data
  Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.localTransactions.clear();
      await isar.localCustomers.clear();
    });
  }
}
