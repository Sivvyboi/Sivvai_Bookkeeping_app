import 'package:flutter/material.dart';
import '../services/security_service.dart';

class SecurityProvider with ChangeNotifier {
  final SecurityService _securityService = SecurityService();

  bool _isLockEnabled = false;
  bool _isBiometricsAvailable = false;

  bool get isLockEnabled => _isLockEnabled;
  bool get isBiometricsAvailable => _isBiometricsAvailable;

  SecurityProvider() {
    _init();
  }

  Future<void> _init() async {
    _isBiometricsAvailable = await _securityService.isBiometricsAvailable();
    _isLockEnabled = await _securityService.isLockEnabled();
    notifyListeners();
  }

  Future<bool> toggleLock(bool enable) async {
    if (enable) {
      // Prompt user to verify fingerprint/face BEFORE enabling the toggle
      final authenticated = await _securityService.authenticate();
      if (authenticated) {
        _isLockEnabled = true;
        await _securityService.setLockEnabled(true);
        notifyListeners();
        return true;
      } else {
        return false; // Auth failed or canceled
      }
    } else {
      _isLockEnabled = false;
      await _securityService.setLockEnabled(false);
      notifyListeners();
      return true;
    }
  }

  Future<bool> authenticate() async {
    if (!_isLockEnabled) return true; // Skip if lock isn't active
    return await _securityService.authenticate();
  }
}