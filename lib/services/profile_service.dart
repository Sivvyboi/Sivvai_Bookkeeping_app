import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/app_profile.dart';

/// Manages the "meta" Isar instance that persists [AppProfile] records.
///
/// This service is completely separate from [DatabaseService] — it owns a
/// dedicated named Isar instance so profile metadata is never entangled with
/// transactional data.
class ProfileService {
  ProfileService._();
  static final ProfileService _instance = ProfileService._();
  factory ProfileService() => _instance;

  static late Isar _metaIsar;

  // ── Initialisation ──────────────────────────────────────────────────────

  /// Must be called once before any other method (replaces the old
  /// [DatabaseService.init] call in main.dart).
  ///
  /// Opens the meta database and guarantees at least one default profile exists.
  static Future<AppProfile> init() async {
    final dir = await getApplicationDocumentsDirectory();

    _metaIsar = await Isar.open(
      [AppProfileSchema],
      directory: dir.path,
      name: 'meta',
    );

    // Seed a default profile if none exist yet.
    final existing = await _metaIsar.appProfiles.where().findAll();
    if (existing.isEmpty) {
      return _createProfileInternal('Personal', isDefault: true);
    }

    // Return whichever profile is marked as default (or fall back to the first).
    return existing.firstWhere(
      (p) => p.isDefault,
      orElse: () => existing.first,
    );
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  Future<List<AppProfile>> getProfiles() async {
    return await _metaIsar.appProfiles
        .where()
        .sortByCreatedAt()
        .findAll();
  }

  Stream<List<AppProfile>> watchProfiles() {
    return _metaIsar.appProfiles
        .where()
        .sortByCreatedAt()
        .watch(fireImmediately: true);
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<AppProfile> createProfile(String name) async {
    return _createProfileInternal(name, isDefault: false);
  }

  Future<void> setDefaultProfile(AppProfile profile) async {
    await _metaIsar.writeTxn(() async {
      // Clear existing default flags.
      final all = await _metaIsar.appProfiles.where().findAll();
      for (final p in all) {
        if (p.isDefault) {
          p.isDefault = false;
          await _metaIsar.appProfiles.put(p);
        }
      }
      profile.isDefault = true;
      await _metaIsar.appProfiles.put(profile);
    });
  }

  Future<void> deleteProfile(AppProfile profile) async {
    await _metaIsar.writeTxn(() async {
      await _metaIsar.appProfiles.delete(profile.id);
    });
    // If this was the default, promote the next available profile.
    if (profile.isDefault) {
      final remaining = await _metaIsar.appProfiles.where().findAll();
      if (remaining.isNotEmpty) {
        await setDefaultProfile(remaining.first);
      }
    }
  }

  Future<void> renameProfile(AppProfile profile, String newName) async {
    profile.name = newName;
    await _metaIsar.writeTxn(() async {
      await _metaIsar.appProfiles.put(profile);
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static Future<AppProfile> _createProfileInternal(
    String name, {
    required bool isDefault,
  }) async {
    final slug = _slugify(name);

    final profile = AppProfile()
      ..name = name
      ..isarName = 'profile_$slug'
      ..createdAt = DateTime.now()
      ..isDefault = isDefault;

    await _metaIsar.writeTxn(() async {
      await _metaIsar.appProfiles.put(profile);
    });

    return profile;
  }

  /// Converts a display name into a safe Isar instance identifier.
  /// e.g. "Business 1" → "business_1"
  static String _slugify(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}
