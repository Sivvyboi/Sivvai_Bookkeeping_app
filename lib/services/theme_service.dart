import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ThemeService {
  static const String _fileName = 'theme_preference.txt';

  /// Saves the chosen ThemeMode to local storage
  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      await file.writeAsString(mode.toString());
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Loads the saved ThemeMode from local storage
  Future<ThemeMode> loadThemeMode() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        return ThemeMode.values.firstWhere(
          (e) => e.toString() == content,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
    return ThemeMode.system;
  }
}
