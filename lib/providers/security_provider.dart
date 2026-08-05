import 'package:flutter/material.dart';
import '../services/security_service.dart';

class SecurityProvider with ChangeNotifier {
  final SecurityService _securityService = SecurityService();

  bool _isLockEnabled = false;
  bool _isBiometricsAvailable = false;
  bool _isInitialized = false; // Track initialization state

  bool get isLockEnabled => _isLockEnabled;
  bool get isBiometricsAvailable => _isBiometricsAvailable;

  SecurityProvider() {
    _init();
  }

  Future<void> _init() async {
    _isBiometricsAvailable = await _securityService.isBiometricsAvailable();
    _isLockEnabled = await _securityService.isLockEnabled();
    _isInitialized = true;
    notifyListeners();
  }

  // Ensures preferences are loaded before checking lock status
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _init();
    }
  }

  Future<bool> toggleLock(bool enable) async {
    await ensureInitialized();
    if (enable) {
      final authenticated = await _securityService.authenticate();
      if (authenticated) {
        _isLockEnabled = true;
        await _securityService.setLockEnabled(true);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } else {
      _isLockEnabled = false;
      await _securityService.setLockEnabled(false);
      notifyListeners();
      return true;
    }
  }

  Future<bool> authenticate() async {
    await ensureInitialized(); // MUST wait for SharedPreferences to complete
    if (!_isLockEnabled) return true;
    return await _securityService.authenticate();
  }
}