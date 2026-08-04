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
    _isLockEnabled = await _securityService.isLockEnabled();
    _isBiometricsAvailable = await _securityService.isBiometricsAvailable();
    notifyListeners();
  }

  Future<void> toggleLock(bool value) async {
    await _securityService.setLockEnabled(value);
    _isLockEnabled = value;
    notifyListeners();
  }

  Future<bool> authenticate() async {
    if (!_isLockEnabled) return true;
    return await _securityService.authenticate();
  }
}
