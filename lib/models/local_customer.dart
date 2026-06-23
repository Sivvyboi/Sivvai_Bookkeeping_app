import 'package:isar/isar.dart';

part 'local_customer.g.dart';

@Collection()
class LocalCustomer {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String fullName;

  String? phoneNumber;

  /// Current balance for this contact.
  /// If relationType is 'DEBTOR', positive means they owe us.
  /// If relationType is 'CREDITOR', positive means we owe them.
  double totalDebtAmount = 0.0;

  /// 'DEBTOR' or 'CREDITOR'
  late String relationType;

  /// Timestamp of the last transaction associated with this customer.
  DateTime? lastUsed;
}
