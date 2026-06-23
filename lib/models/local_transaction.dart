import 'package:isar/isar.dart';
import 'local_customer.dart';

part 'local_transaction.g.dart';

@Collection()
class LocalTransaction {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime timestamp;

  late double amount;

  /// Either 'INFLOW', 'OUTFLOW' or 'PAYMENT'
  late String transactionType;

  String? remarks;

  /// Whether this was a credit/debt transaction (not immediate cash)
  bool isCredit = false;

  final customer = IsarLink<LocalCustomer>();
}
