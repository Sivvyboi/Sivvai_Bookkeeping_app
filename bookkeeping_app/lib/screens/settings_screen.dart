import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/size_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
          SizedBox(height: 4.h),
          _buildSectionHeader(context, 'Data & Backup'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.share, color: theme.colorScheme.primary),
                  title: Text('Export Backup', style: TextStyle(fontSize: 15.sp)),
                  subtitle: const Text('Share backup file via WhatsApp/Email'),
                  onTap: () async {
                    final provider = context.read<TransactionProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await provider.exportData();
                    if (success) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Backup exported successfully!')),
                      );
                    }
                  },
                ),
                Divider(height: 1, color: theme.dividerTheme.color),
                ListTile(
                  leading: const Icon(Icons.upload_file, color: Colors.orange),
                  title: Text('Restore from Backup', style: TextStyle(fontSize: 15.sp)),
                  subtitle: const Text('Upload a previously saved .json file'),
                  onTap: () async {
                    final provider = context.read<TransactionProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await provider.importData();
                    if (success) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Data restored successfully!')),
                      );
                    }
                  },
                ),
                Divider(height: 1, color: theme.dividerTheme.color),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Clear All Data', style: TextStyle(color: Colors.red, fontSize: 15.sp)),
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
                  color: isSelected ? colorScheme.onPrimary : colorScheme.primary
                ),
                SizedBox(height: 0.5.h),
                Text(
                  label, 
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                  )
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('This will permanently delete ALL transactions and customers. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<TransactionProvider>();
              final navigator = Navigator.of(context);
              await provider.deleteAllData();
              navigator.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
