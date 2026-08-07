import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/local_customer.dart';
import '../models/local_transaction.dart';
import '../models/app_profile.dart';
import 'profile_service.dart';

class DatabaseService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  DatabaseService._();
  static final DatabaseService _instance = DatabaseService._();
  factory DatabaseService() => _instance;

  /// The currently active profile's Isar instance.
  /// Set by [switchToProfile] before any CRUD is performed.
  static late Isar isar;

  // ── Profile Switching ─────────────────────────────────────────────────────

  /// Opens (or re-uses) the Isar data instance for [profile].
  ///
  /// - If a different profile instance is open, it is closed first.
  /// - On first launch the meta Isar instance (managed by [ProfileService])
  ///   is already open; this method only manages the *data* instances.
  static Future<void> switchToProfile(AppProfile profile) async {
    final dir = await getApplicationDocumentsDirectory();

    // Close any previously open data instance (but NOT the 'meta' instance).
    if (Isar.getInstance(profile.isarName) == null) {
      // Close old instance(s) that are not 'meta'.
      for (final instance in Isar.instanceNames) {
        if (instance != 'meta') {
          final old = Isar.getInstance(instance);
          await old?.close();
        }
      }

      isar = await Isar.open(
        [LocalCustomerSchema, LocalTransactionSchema],
        directory: dir.path,
        name: profile.isarName,
      );
    } else {
      // Already open — just reuse it.
      isar = Isar.getInstance(profile.isarName)!;
    }

    // Run legacy migration on the newly-opened instance.
    await _migrateLegacyPayments();
  }

  // ── Migration ─────────────────────────────────────────────────────────────

  static Future<void> _migrateLegacyPayments() async {
    final legacyPayments = await isar.localTransactions
        .filter()
        .transactionTypeEqualTo('PAYMENT')
        .findAll();

    if (legacyPayments.isNotEmpty) {
      await isar.writeTxn(() async {
        for (var p in legacyPayments) {
          await p.customer.load();
          if (p.customer.value == null ||
              p.customer.value!.relationType == 'DEBTOR') {
            p.transactionType = 'PAYMENT_IN';
          } else {
            p.transactionType = 'PAYMENT_OUT';
          }
          await isar.localTransactions.put(p);
        }
      });
    }
  }

  // ── Transactions ──────────────────────────────────────────────────────────

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
      if (customer != null) {
        customer.lastUsed = now;
        await isar.localCustomers.put(customer);
        newTransaction.customer.value = customer;
      }
      await isar.localTransactions.put(newTransaction);
      if (customer != null) {
        await newTransaction.customer.save();
        await _recalculateCustomerDebt(customer.id);
      }
    });
  }

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
      if (customer != null &&
          (oldCustomer == null || customer.id != oldCustomer.id)) {
        await _recalculateCustomerDebt(customer.id);
      }
    });
  }

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

    final baseQuery =
        isar.localTransactions.filter().customer((q) => q.idEqualTo(customerId));

    final creditInflows = await baseQuery
        .transactionTypeEqualTo('INFLOW')
        .isCreditEqualTo(true)
        .amountProperty()
        .sum();
    final creditOutflows = await baseQuery
        .transactionTypeEqualTo('OUTFLOW')
        .isCreditEqualTo(true)
        .amountProperty()
        .sum();
    final paymentsIn = await baseQuery
        .transactionTypeEqualTo('PAYMENT_IN')
        .amountProperty()
        .sum();
    final paymentsOut = await baseQuery
        .transactionTypeEqualTo('PAYMENT_OUT')
        .amountProperty()
        .sum();

    double balance = creditInflows - creditOutflows;
    balance -= paymentsIn;
    balance += paymentsOut;

    if (balance >= 0) {
      customer.relationType = 'DEBTOR';
      customer.totalDebtAmount = balance;
    } else {
      customer.relationType = 'CREDITOR';
      customer.totalDebtAmount = -balance;
    }

    await isar.localCustomers.put(customer);
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  Stream<List<LocalTransaction>> watchTransactions({
    DateTime? start,
    DateTime? end,
  }) {
    final query = isar.localTransactions.where();

    if (start != null && end != null) {
      return query
          .filter()
          .timestampBetween(start, end)
          .sortByTimestampDesc()
          .watch(fireImmediately: true);
    } else if (start != null) {
      return query
          .filter()
          .timestampGreaterThan(start, include: true)
          .sortByTimestampDesc()
          .watch(fireImmediately: true);
    } else if (end != null) {
      return query
          .filter()
          .timestampLessThan(end, include: true)
          .sortByTimestampDesc()
          .watch(fireImmediately: true);
    }

    return query.sortByTimestampDesc().watch(fireImmediately: true);
  }

  // ── Customers ─────────────────────────────────────────────────────────────

  Future<LocalCustomer> addCustomer(
    String name, {
    String? phone,
    required String relationType,
  }) async {
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

  Future<void> updateCustomer(LocalCustomer customer) async {
    await isar.writeTxn(() async {
      await isar.localCustomers.put(customer);
    });
  }

  Future<void> deleteCustomer(int id) async {
    await isar.writeTxn(() async {
      await isar.localCustomers.delete(id);
    });
  }

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

  Future<List<LocalCustomer>> getCustomers() async {
    return await isar.localCustomers.where().sortByLastUsedDesc().findAll();
  }

  Stream<List<LocalCustomer>> watchCustomers() {
    return isar.localCustomers
        .where()
        .sortByLastUsedDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<LocalTransaction>> watchCustomerTransactions(int customerId) {
    return isar.localTransactions
        .filter()
        .customer((q) => q.idEqualTo(customerId))
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  // ── Backup / Restore ──────────────────────────────────────────────────────

  // ── Multi-Profile Cloud Backup / Restore ────────────────────────────────

  /// Exports all created profiles, contacts, and transactions into a unified multi-profile JSON snapshot.
  Future<String> exportFullMultiProfileBackup() async {
    final profiles = await ProfileService().getProfiles();
    final dir = await getApplicationDocumentsDirectory();

    final List<Map<String, dynamic>> profilesJson = [];
    final Map<String, Map<String, dynamic>> profilesDataJson = {};

    for (final p in profiles) {
      profilesJson.add({
        'id': p.id,
        'name': p.name,
        'isarName': p.isarName,
        'createdAt': p.createdAt.toIso8601String(),
        'isDefault': p.isDefault,
      });

      final pIsar = Isar.getInstance(p.isarName) ??
          await Isar.open(
            [LocalCustomerSchema, LocalTransactionSchema],
            directory: dir.path,
            name: p.isarName,
          );

      final customers = await pIsar.localCustomers.where().findAll();
      final transactions = await pIsar.localTransactions.where().findAll();

      final transactionDataList = [];
      for (var t in transactions) {
        await t.customer.load();
        transactionDataList.add({
          'amount': t.amount,
          'timestamp': t.timestamp.toIso8601String(),
          'transactionType': t.transactionType,
          'remarks': t.remarks ?? '',
          'isCredit': t.isCredit,
          'customerName': t.customer.value?.fullName,
        });
      }

      profilesDataJson[p.isarName] = {
        'customers': customers
            .map((c) => {
                  'fullName': c.fullName,
                  'phoneNumber': c.phoneNumber ?? '',
                  'totalDebtAmount': c.totalDebtAmount,
                  'relationType': c.relationType,
                  'lastUsed': c.lastUsed?.toIso8601String(),
                })
            .toList(),
        'transactions': transactionDataList,
      };
    }

    final backupPayload = {
      'version': 7,
      'type': 'multi_profile_backup',
      'exportedAt': DateTime.now().toIso8601String(),
      'profiles': profilesJson,
      'profilesData': profilesDataJson,
    };

    final jsonString = jsonEncode(backupPayload);
    final directory = await getTemporaryDirectory();
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/bookkeeper_multibackup_$dateStr.json');
    await file.writeAsString(jsonString);
    return file.path;
  }

  /// Restores multi-profile cloud backup payload into local Isar database instances.
  Future<AppProfile> importFullMultiProfileBackup(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString.trim());

    // Legacy single-profile fallback
    if (!data.containsKey('profilesData')) {
      await importBackup(jsonString);
      final profiles = await ProfileService().getProfiles();
      return profiles.firstWhere((p) => p.isDefault, orElse: () => profiles.first);
    }

    final dir = await getApplicationDocumentsDirectory();
    final profilesJson = data['profiles'] as List;
    final restoredProfiles = await ProfileService().restoreProfiles(profilesJson);

    final profilesData = data['profilesData'] as Map<String, dynamic>;

    for (final p in restoredProfiles) {
      final pData = profilesData[p.isarName] as Map<String, dynamic>?;
      if (pData == null) continue;

      final pIsar = Isar.getInstance(p.isarName) ??
          await Isar.open(
            [LocalCustomerSchema, LocalTransactionSchema],
            directory: dir.path,
            name: p.isarName,
          );

      await pIsar.writeTxn(() async {
        await pIsar.localTransactions.clear();
        await pIsar.localCustomers.clear();

        final Map<String, LocalCustomer> nameToCustomer = {};

        final customersData = pData['customers'] as List;
        for (var cData in customersData) {
          final customer = LocalCustomer()
            ..fullName = cData['fullName']
            ..phoneNumber = cData['phoneNumber']
            ..totalDebtAmount = (cData['totalDebtAmount'] as num).toDouble()
            ..relationType = cData['relationType'] ?? 'DEBTOR'
            ..lastUsed = cData['lastUsed'] != null
                ? DateTime.parse(cData['lastUsed'])
                : null;

          await pIsar.localCustomers.put(customer);
          nameToCustomer[customer.fullName] = customer;
        }

        final transactionsData = pData['transactions'] as List;
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

          await pIsar.localTransactions.put(transaction);
        }
      });
    }

    final activeProfile = restoredProfiles.firstWhere(
      (p) => p.isDefault,
      orElse: () => restoredProfiles.first,
    );

    await switchToProfile(activeProfile);
    return activeProfile;
  }

  Future<String> exportBackup({String? profileName}) async {
    return exportFullMultiProfileBackup();
  }

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
          ..totalDebtAmount =
              (cData['totalDebtAmount'] as num).toDouble()
          ..relationType = cData['relationType'] ?? 'DEBTOR'
          ..lastUsed = cData['lastUsed'] != null
              ? DateTime.parse(cData['lastUsed'])
              : null;

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
        if (customerName != null &&
            nameToCustomer.containsKey(customerName)) {
          transaction.customer.value = nameToCustomer[customerName];
        }

        await isar.localTransactions.put(transaction);
      }
    });
  }

  /// Wipes all data across all profiles, resets profiles in [ProfileService] to a single default profile, and switches to it.
  Future<AppProfile> wipeAllData() async {
    final profiles = await ProfileService().getProfiles();
    final dir = await getApplicationDocumentsDirectory();

    for (final p in profiles) {
      final pIsar = Isar.getInstance(p.isarName) ??
          await Isar.open(
            [LocalCustomerSchema, LocalTransactionSchema],
            directory: dir.path,
            name: p.isarName,
          );
      await pIsar.writeTxn(() async {
        await pIsar.localTransactions.clear();
        await pIsar.localCustomers.clear();
      });
    }

    final defaultProfile = await ProfileService().resetToDefault();
    await switchToProfile(defaultProfile);
    return defaultProfile;
  }
}
