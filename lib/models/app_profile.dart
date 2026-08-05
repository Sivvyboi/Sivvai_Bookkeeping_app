import 'package:isar/isar.dart';

part 'app_profile.g.dart';

/// Stored in the shared 'meta' Isar instance.
/// Each profile record maps to a separate named Isar data instance.
@Collection()
class AppProfile {
  Id id = Isar.autoIncrement;

  /// Human-readable display name (e.g. "Personal", "Business 1").
  late String name;

  /// The unique Isar instance name for this profile's data (slugified).
  /// e.g. "profile_personal", "profile_business_1"
  @Index(unique: true)
  late String isarName;

  /// When this profile was created.
  late DateTime createdAt;

  /// Whether this profile should auto-load on startup.
  bool isDefault = false;
}
