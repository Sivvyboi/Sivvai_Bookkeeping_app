import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/security_provider.dart';
import '../providers/profile_provider.dart';
import '../services/drive_backup_service.dart';
import '../services/database_service.dart';
import '../widgets/export_dialog.dart';
import '../widgets/themed_dialogs.dart';
import '../utils/size_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canPop = Navigator.canPop(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Seamless Custom Top Header ──────
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 8,
              left: 2.w,
              right: 4.w,
              bottom: 1.h,
            ),
            child: Row(
              children: [
                if (canPop)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                else
                  SizedBox(width: 2.w),
                Text(
                  'Settings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              children: [
                _buildSectionHeader(context, 'Appearance'),
                Card(
                  child: ExpansionTile(
                    leading: Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                    title: Text('App Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
                    subtitle: Text(
                      _getThemeModeName(themeProvider.currentThemeMode),
                      style: TextStyle(fontSize: 12.sp, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6)),
                    ),
                    initiallyExpanded: false,
                    shape: const RoundedRectangleBorder(side: BorderSide.none),
                    collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                    childrenPadding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 2.5.h, top: 0.5.h),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildThemeChip(context, 'Light', Icons.light_mode, ThemeMode.light, themeProvider),
                          _buildThemeChip(context, 'Dark', Icons.dark_mode, ThemeMode.dark, themeProvider),
                          _buildThemeChip(context, 'System', Icons.brightness_auto, ThemeMode.system, themeProvider),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                _buildSectionHeader(context, 'Security'),
                Consumer<SecurityProvider>(
                  builder: (context, security, child) {
                    return Card(
                      child: SwitchListTile(
                        secondary: Icon(Icons.fingerprint, color: theme.colorScheme.primary),
                        title: Text('App Lock', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
                        subtitle: Text(
                          security.isBiometricsAvailable
                              ? 'Protect your data with Biometrics'
                              : 'Biometrics not supported on this device',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        value: security.isLockEnabled,
                        onChanged: security.isBiometricsAvailable
                            ? (val) => security.toggleLock(val)
                            : null,
                      ),
                    );
                  },
                ),
                SizedBox(height: 4.h),

                // ── Cloud Backup & Sync Section ──
                const _CloudBackupSection(),
                SizedBox(height: 4.h),

                _buildSectionHeader(context, 'Data & Export'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.picture_as_pdf_outlined, color: theme.colorScheme.primary),
                        title: Text('Export Financial Reports', style: TextStyle(fontSize: 15.sp)),
                        subtitle: Consumer<ProfileProvider>(
                          builder: (context, profileProvider, _) {
                            final activeName = profileProvider.activeProfile?.name ?? 'Active Profile';
                            return Text('Generate PDF or Excel sheets for $activeName');
                          },
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const ExportDialog(),
                          );
                        },
                      ),
                      Divider(height: 1, color: theme.dividerTheme.color),
                      ListTile(
                        leading: const Icon(Icons.delete_forever, color: Colors.red),
                        title: Text('Reset App & Clear All Data', style: TextStyle(color: Colors.red, fontSize: 15.sp)),
                        subtitle: const Text('Wipe all profiles, transactions, and contacts clean'),
                        onTap: () => _showDeleteConfirmation(context),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6.h),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Bookkeeper',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                        ),
                      ),
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow System Settings';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  Widget _buildThemeChip(BuildContext context, String label, IconData icon, ThemeMode mode, ThemeProvider provider) {
    final isSelected = provider.currentThemeMode == mode;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        child: ChoiceChip(
          label: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) provider.updateThemeMode(mode);
          },
          showCheckmark: false,
          padding: EdgeInsets.symmetric(vertical: 1.2.h),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 1.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    ThemedDialogs.showDeleteConfirmation(
      context,
      itemType: 'all app data & profiles',
      detail: 'This will permanently wipe ALL profiles, transactions, and contacts clean like a brand new app.',
    ).then((confirmed) async {
      if (confirmed == true && context.mounted) {
        final txProvider = context.read<TransactionProvider>();
        final profileProvider = context.read<ProfileProvider>();
        final defaultProfile = await DatabaseService().wipeAllData();
        profileProvider.resetProfiles(defaultProfile);
        await txProvider.reinitialize();
        if (context.mounted) {
          ThemedDialogs.showSuccessSnackBar(context, 'App state wiped clean like a new app!');
        }
      }
    });
  }
}

class _CloudBackupSection extends StatefulWidget {
  const _CloudBackupSection();

  @override
  State<_CloudBackupSection> createState() => _CloudBackupSectionState();
}

class _CloudBackupSectionState extends State<_CloudBackupSection> {
  final DriveBackupService _driveService = DriveBackupService();

  bool _isAutoBackup = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isSigningIn = false;

  DriveBackupInfo _backupInfo = DriveBackupInfo(status: 'No backups yet');
  GoogleSignInAccount? _googleUser;
  StreamSubscription<GoogleSignInAccount?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initCloudBackupState();
    _authSubscription = _driveService.onCurrentUserChanged.listen((account) {
      if (mounted) {
        setState(() {
          _googleUser = account;
        });
        _refreshBackupInfo();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initCloudBackupState() async {
    _googleUser = _driveService.currentUser ?? await _driveService.signInSilently();
    final autoEnabled = await _driveService.isAutoBackupEnabled();
    final info = await _driveService.getLastBackupInfo();

    if (mounted) {
      setState(() {
        _isAutoBackup = autoEnabled;
        _backupInfo = info;
      });
    }
  }

  Future<void> _refreshBackupInfo() async {
    final info = await _driveService.getLastBackupInfo();
    if (mounted) {
      setState(() {
        _backupInfo = info;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);
    try {
      final account = await _driveService.signIn();
      if (account != null && mounted) {
        ThemedDialogs.showSuccessSnackBar(
          context,
          'Connected as ${account.email}',
        );
      }
    } catch (e) {
      if (mounted) {
        final cleanMsg = DriveBackupService.getUserFriendlyErrorMessage(e);
        ThemedDialogs.showErrorSnackBar(
          context,
          'Google Sign-In failed: $cleanMsg',
        );
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _handleGoogleSignOut() async {
    try {
      await _driveService.signOut();
      if (mounted) {
        ThemedDialogs.showSuccessSnackBar(
          context,
          'Signed out from Google',
        );
      }
    } catch (e) {
      if (mounted) {
        final cleanMsg = DriveBackupService.getUserFriendlyErrorMessage(e);
        ThemedDialogs.showErrorSnackBar(
          context,
          'Sign-out failed: $cleanMsg',
        );
      }
    }
  }

  Future<void> _toggleAutoBackup(bool enabled) async {
    await _driveService.setAutoBackupEnabled(enabled);
    setState(() {
      _isAutoBackup = enabled;
    });
    if (mounted) {
      ThemedDialogs.showSuccessSnackBar(
        context,
        enabled ? 'Auto-backup enabled' : 'Auto-backup disabled',
      );
    }
  }

  Future<void> _performManualBackup() async {
    if (_isBackingUp) return;
    setState(() => _isBackingUp = true);

    try {
      final profileName = context.read<ProfileProvider>().activeProfile?.name ?? 'Default';
      final success = await _driveService.uploadBackup(profileName: profileName);
      await _refreshBackupInfo();

      if (success && mounted) {
        ThemedDialogs.showSuccessSnackBar(
          context,
          'Backup successfully uploaded to Google Drive!',
        );
      }
    } catch (e) {
      await _refreshBackupInfo();
      if (mounted) {
        final cleanMsg = DriveBackupService.getUserFriendlyErrorMessage(e);
        ThemedDialogs.showErrorSnackBar(
          context,
          'Backup failed: $cleanMsg',
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _performRestore() async {
    if (_isRestoring) return;

    final info = await _driveService.getLastBackupInfo();
    if (!mounted) return;

    final backupDateStr = info.lastBackupDate != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(info.lastBackupDate!)
        : null;

    final confirmed = await ThemedDialogs.showRestoreConfirmation(
      context,
      backupDate: backupDateStr,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isRestoring = true);

    try {
      await context.read<TransactionProvider>().pauseWatchers();
      await _driveService.restoreLatestBackup();
      if (!mounted) return;

      await context.read<TransactionProvider>().reinitialize();
      if (!mounted) return;

      ThemedDialogs.showSuccessSnackBar(
        context,
        'All profiles and data successfully restored from Google Drive!',
      );
    } catch (e) {
      if (mounted) {
        final cleanMsg = DriveBackupService.getUserFriendlyErrorMessage(e);
        ThemedDialogs.showErrorSnackBar(
          context,
          'Restore failed: $cleanMsg',
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  String _getBackupSubtitle() {
    if (_backupInfo.lastBackupDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(_backupInfo.lastBackupDate!);
      return 'Last backup: $formattedDate (${_backupInfo.formattedSize})';
    }
    if (_backupInfo.status.startsWith('Failed: ')) {
      final rawMsg = _backupInfo.status.substring(8);
      final cleanMsg = DriveBackupService.getUserFriendlyErrorMessage(rawMsg);
      return 'Status: Failed ($cleanMsg)';
    }
    return 'Status: ${_backupInfo.status}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = _googleUser != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 1.h),
          child: Text(
            'CLOUD BACKUP & SYNC',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              // Google Account Connection Tile
              ListTile(
                leading: isConnected
                    ? CircleAvatar(
                        radius: 16,
                        backgroundImage: _googleUser?.photoUrl != null
                            ? NetworkImage(_googleUser!.photoUrl!)
                            : null,
                        child: _googleUser?.photoUrl == null
                            ? const Icon(Icons.person, size: 20)
                            : null,
                      )
                    : Icon(Icons.cloud_off_outlined, color: theme.colorScheme.primary),
                title: Text(
                  isConnected ? (_googleUser?.displayName ?? 'Google User') : 'Google Account',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  isConnected
                      ? 'Connected as ${_googleUser?.email}'
                      : 'Tap to connect your Google Account',
                  style: TextStyle(fontSize: 12.sp),
                ),
                trailing: isConnected
                    ? IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                        tooltip: 'Disconnect Google Account',
                        onPressed: _handleGoogleSignOut,
                      )
                    : _isSigningIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.arrow_forward_ios, size: 14.sp, color: theme.hintColor),
                onTap: isConnected ? null : _handleGoogleSignIn,
              ),
              Divider(height: 1, color: theme.dividerTheme.color),

              // Auto-Backup Switch Tile
              SwitchListTile(
                secondary: Icon(Icons.sync, color: theme.colorScheme.primary),
                title: Text('Auto-Backup to Cloud', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  isConnected
                      ? 'Back up automatically on profile switch or app pause'
                      : 'Connect Google Account to enable auto-backup',
                  style: TextStyle(fontSize: 12.sp),
                ),
                value: _isAutoBackup && isConnected,
                onChanged: isConnected ? _toggleAutoBackup : null,
              ),
              Divider(height: 1, color: theme.dividerTheme.color),

              // Manual Backup Tile
              ListTile(
                leading: Icon(Icons.cloud_upload_outlined, color: theme.colorScheme.primary),
                title: Text('Back Up Now', style: TextStyle(fontSize: 15.sp)),
                subtitle: Text(_getBackupSubtitle(), style: TextStyle(fontSize: 12.sp)),
                trailing: _isBackingUp
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.arrow_forward_ios, size: 14.sp, color: theme.hintColor),
                enabled: isConnected && !_isBackingUp,
                onTap: isConnected && !_isBackingUp ? _performManualBackup : null,
              ),
              Divider(height: 1, color: theme.dividerTheme.color),

              // Restore Tile
              ListTile(
                leading: const Icon(Icons.cloud_download_outlined, color: Colors.orange),
                title: Text('Restore Data', style: TextStyle(fontSize: 15.sp)),
                subtitle: const Text('Download & overwrite local state with Google Drive backup'),
                trailing: _isRestoring
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.arrow_forward_ios, size: 14.sp, color: theme.hintColor),
                enabled: isConnected && !_isRestoring,
                onTap: isConnected && !_isRestoring ? _performRestore : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
