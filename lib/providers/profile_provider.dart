import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_profile.dart';
import '../services/profile_service.dart';
import '../services/database_service.dart';

/// Manages the list of profiles and the currently active profile.
///
/// After a profile switch, callers (e.g. [TransactionProvider]) should listen
/// to [activeProfile] changes and call their own reinitialize() method.
class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  List<AppProfile> _profiles = [];
  AppProfile? _activeProfile;
  bool _isSwitching = false;
  String? _errorMessage;

  StreamSubscription<List<AppProfile>>? _profileSubscription;

  ProfileProvider() {
    _init();
  }

  // ── Getters ───────────────────────────────────────────────────────────────

  List<AppProfile> get profiles => _profiles;
  AppProfile? get activeProfile => _activeProfile;
  bool get isSwitching => _isSwitching;
  String? get errorMessage => _errorMessage;

  // ── Initialisation ────────────────────────────────────────────────────────

  void _init() {
    _profileSubscription =
        _profileService.watchProfiles().listen((data) {
      _profiles = data;
      // Keep activeProfile reference up to date after renames / deletes.
      if (_activeProfile != null) {
        _activeProfile = _profiles.firstWhere(
          (p) => p.id == _activeProfile!.id,
          orElse: () => _profiles.isNotEmpty ? _profiles.first : _activeProfile!,
        );
      }
      notifyListeners();
    });
  }

  /// Called by main.dart / splash screen once [ProfileService.init()] has
  /// returned the default [AppProfile] and [DatabaseService.switchToProfile()]
  /// has been called.
  void setActiveProfileAfterInit(AppProfile profile) {
    _activeProfile = profile;
    notifyListeners();
  }

  // ── Profile Switching ─────────────────────────────────────────────────────

  /// Switches the active profile.
  ///
  /// Callers should pass a [onSwitched] callback that re-initialises any
  /// providers that hold live Isar stream subscriptions.
  Future<void> switchProfile(
    AppProfile profile, {
    Future<void> Function()? onSwitched,
  }) async {
    if (_activeProfile?.id == profile.id) return;

    _isSwitching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DatabaseService.switchToProfile(profile);
      _activeProfile = profile;
      if (onSwitched != null) await onSwitched();
    } catch (e) {
      _errorMessage = 'Failed to switch profile: ${e.toString()}';
    } finally {
      _isSwitching = false;
      notifyListeners();
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<AppProfile?> createProfile(String name) async {
    _errorMessage = null;
    try {
      final profile = await _profileService.createProfile(name);
      return profile;
    } catch (e) {
      _errorMessage = 'Failed to create profile: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<void> renameProfile(AppProfile profile, String newName) async {
    _errorMessage = null;
    try {
      await _profileService.renameProfile(profile, newName);
    } catch (e) {
      _errorMessage = 'Failed to rename profile: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Deletes a profile. Returns false if it is the last remaining profile.
  Future<bool> deleteProfile(AppProfile profile) async {
    if (_profiles.length <= 1) {
      _errorMessage = 'You cannot delete your only profile.';
      notifyListeners();
      return false;
    }
    _errorMessage = null;
    try {
      await _profileService.deleteProfile(profile);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete profile: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
