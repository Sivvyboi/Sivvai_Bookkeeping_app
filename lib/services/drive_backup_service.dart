import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class DriveBackupItem {
  final String id;
  final String name;
  final DateTime timestamp;
  final int sizeBytes;
  final String profileName;

  DriveBackupItem({
    required this.id,
    required this.name,
    required this.timestamp,
    required this.sizeBytes,
    required this.profileName,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class DriveBackupInfo {
  final DateTime? lastBackupDate;
  final int? lastBackupSizeBytes;
  final String status;

  DriveBackupInfo({
    this.lastBackupDate,
    this.lastBackupSizeBytes,
    required this.status,
  });

  String get formattedSize {
    if (lastBackupSizeBytes == null || lastBackupSizeBytes == 0) return '0 KB';
    if (lastBackupSizeBytes! < 1024) return '$lastBackupSizeBytes B';
    if (lastBackupSizeBytes! < 1024 * 1024) {
      return '${(lastBackupSizeBytes! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(lastBackupSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Service for Google Drive backup, restore, and authentication with appDataFolder scope.
class DriveBackupService {
  DriveBackupService._();
  static final DriveBackupService _instance = DriveBackupService._();
  factory DriveBackupService() => _instance;

  static const String _keyAutoBackup = 'drive_auto_backup_enabled';
  static const String _keyLastTimestamp = 'drive_last_backup_timestamp';
  static const String _keyLastSize = 'drive_last_backup_size';
  static const String _keyLastStatus = 'drive_last_backup_status';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  Stream<GoogleSignInAccount?> get onCurrentUserChanged => _googleSignIn.onCurrentUserChanged;
  bool get isSignedIn => _googleSignIn.currentUser != null;

  // ── Authentication Methods ────────────────────────────────────────────────

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      rethrow;
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      debugPrint('Google Sign-In Silently failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google Sign-Out failed: $e');
    }
  }

  // ── Auto-Backup Preferences ────────────────────────────────────────────────

  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoBackup) ?? false;
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoBackup, enabled);
  }

  // ── Backup Information ─────────────────────────────────────────────────────

  Future<DriveBackupInfo> getLastBackupInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final tsStr = prefs.getString(_keyLastTimestamp);
    final size = prefs.getInt(_keyLastSize);
    final status = prefs.getString(_keyLastStatus) ?? 'No backups yet';

    DateTime? dt;
    if (tsStr != null) {
      dt = DateTime.tryParse(tsStr);
    }

    return DriveBackupInfo(
      lastBackupDate: dt,
      lastBackupSizeBytes: size,
      status: status,
    );
  }

  // ── Backup & Upload ───────────────────────────────────────────────────────

  /// Serializes local database data into a compressed gzip JSON payload and uploads it to Google Drive's appDataFolder.
  Future<bool> uploadBackup({String profileName = 'Default'}) async {
    try {
      var account = _googleSignIn.currentUser;
      account ??= await signInSilently();
      account ??= await signIn();
      if (account == null) {
        throw Exception('Not signed in to Google.');
      }

      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        throw Exception('Failed to obtain authenticated HTTP client for Google Drive.');
      }

      final driveApi = drive.DriveApi(authClient);

      // Export multi-profile JSON payload using DatabaseService
      final jsonPath = await DatabaseService().exportFullMultiProfileBackup();
      final jsonFile = File(jsonPath);
      final jsonBytes = await jsonFile.readAsBytes();

      // Compress using GZip
      final gzippedBytes = gzip.encode(jsonBytes);
      final totalBytes = gzippedBytes.length;

      final timestampStr = DateTime.now().toIso8601String();
      final dateStamp = DateTime.now().millisecondsSinceEpoch;

      final driveFile = drive.File()
        ..name = 'sivvai_multibackup_${profileName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}_$dateStamp.json.gz'
        ..parents = ['appDataFolder']
        ..appProperties = {
          'profileName': profileName,
          'timestamp': timestampStr,
          'appVersion': '1.0.0',
          'backupType': 'multi_profile',
        };

      final media = drive.Media(
        Stream.value(gzippedBytes),
        totalBytes,
      );

      await driveApi.files.create(driveFile, uploadMedia: media);

      // Clean up local temp file
      if (await jsonFile.exists()) {
        await jsonFile.delete();
      }

      // Record backup info in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastTimestamp, timestampStr);
      await prefs.setInt(_keyLastSize, totalBytes);
      await prefs.setString(_keyLastStatus, 'Success');

      return true;
    } catch (e) {
      debugPrint('Error uploading backup to Google Drive: $e');
      final cleanMsg = getUserFriendlyErrorMessage(e);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastStatus, 'Failed: $cleanMsg');
      throw Exception(cleanMsg);
    }
  }

  // ── Restore Latest Backup ──────────────────────────────────────────────────

  /// Downloads the latest multi-profile snapshot from appDataFolder and safely overwrites local database files.
  Future<bool> restoreLatestBackup() async {
    try {
      var account = _googleSignIn.currentUser;
      account ??= await signInSilently();
      if (account == null) {
        throw Exception('Not signed in to Google.');
      }

      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        throw Exception('Failed to obtain authenticated HTTP client for Google Drive.');
      }

      final driveApi = drive.DriveApi(authClient);

      // Fetch file list from appDataFolder
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, createdTime, modifiedTime, size, appProperties)',
        orderBy: 'modifiedTime desc',
      );

      final files = fileList.files;
      if (files == null || files.isEmpty) {
        throw Exception('No cloud backups found in Google Drive appDataFolder.');
      }

      // Latest backup is the first item
      final latestFile = files.first;
      final fileId = latestFile.id;
      if (fileId == null) {
        throw Exception('Backup file ID is invalid.');
      }

      final drive.Media media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> bytesList = [];
      await for (final chunk in media.stream) {
        bytesList.addAll(chunk);
      }

      // Decompress if gzip encoded or process string
      String jsonString;
      try {
        final decompressedBytes = gzip.decode(bytesList);
        jsonString = utf8.decode(decompressedBytes);
      } catch (_) {
        // Fallback for plain uncompressed JSON if any
        jsonString = utf8.decode(bytesList);
      }

      // Import multi-profile backup into Isar DB
      await DatabaseService().importFullMultiProfileBackup(jsonString);

      return true;
    } catch (e) {
      debugPrint('Error restoring backup from Google Drive: $e');
      final cleanMsg = getUserFriendlyErrorMessage(e);
      throw Exception(cleanMsg);
    }
  }

  /// Converts raw technical network or API exceptions into clean user-friendly messages.
  static String getUserFriendlyErrorMessage(dynamic e) {
    if (e is SocketException ||
        e is http.ClientException ||
        e is HandshakeException) {
      return 'No internet connection. Please check your network and try again.';
    }

    final str = e.toString();
    if (str.contains('SocketException') ||
        str.contains('Failed host lookup') ||
        str.contains('ClientException') ||
        str.contains('HandshakeException') ||
        str.contains('NetworkImageException') ||
        str.contains('No address associated with hostname') ||
        str.contains('Connection refused') ||
        str.contains('Software caused connection abort') ||
        str.contains('Network is unreachable')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (e is Exception) {
      var message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      return message;
    }

    return str;
  }

  // ── List Available Backups ─────────────────────────────────────────────────

  /// Lists all available backup files stored in appDataFolder.
  Future<List<DriveBackupItem>> getAvailableBackups() async {
    try {
      var account = _googleSignIn.currentUser;
      account ??= await signInSilently();
      if (account == null) return [];

      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) return [];

      final driveApi = drive.DriveApi(authClient);

      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, createdTime, modifiedTime, size, appProperties)',
        orderBy: 'modifiedTime desc',
      );

      final items = <DriveBackupItem>[];
      if (fileList.files != null) {
        for (final f in fileList.files!) {
          final id = f.id ?? '';
          final name = f.name ?? 'Backup';
          final ts = f.modifiedTime ?? f.createdTime ?? DateTime.now();
          final size = int.tryParse(f.size ?? '0') ?? 0;
          final profile = f.appProperties?['profileName'] ?? 'Default';

          items.add(DriveBackupItem(
            id: id,
            name: name,
            timestamp: ts,
            sizeBytes: size,
            profileName: profile,
          ));
        }
      }
      return items;
    } catch (e) {
      debugPrint('Error fetching available backups: $e');
      return [];
    }
  }

  // ── Auto-Backup Execution ──────────────────────────────────────────────────

  /// Triggers a background backup if auto-backup is enabled and user is signed in.
  Future<void> performAutoBackup({String profileName = 'Default'}) async {
    try {
      final enabled = await isAutoBackupEnabled();
      if (!enabled) return;

      final account = await signInSilently();
      if (account == null) return;

      debugPrint('Performing automatic Google Drive backup for $profileName...');
      await uploadBackup(profileName: profileName);
    } catch (e) {
      debugPrint('Automatic Google Drive backup failed silently: $e');
    }
  }
}
