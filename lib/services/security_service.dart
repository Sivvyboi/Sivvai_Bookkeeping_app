import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const String _lockKey = 'app_lock_enabled';

  Future<bool> isBiometricsAvailable() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();

      return (canCheckBiometrics || isSupported) && availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access your bookkeeping records',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('Biometric error code: ${e.code}');
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lockKey) ?? false;
  }

  Future<void> setLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockKey, enabled);
  }
}