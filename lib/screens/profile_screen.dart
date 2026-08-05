import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_profile.dart';
import '../providers/profile_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/size_config.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Manage Profiles',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          if (profileProvider.isSwitching) {
            return const Center(child: CircularProgressIndicator());
          }

          final profiles = profileProvider.profiles;
          final active = profileProvider.activeProfile;

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            children: [
              // ── Info banner ────────────────────────────────────────────
              _InfoBanner(),
              SizedBox(height: 2.h),

              // ── Profile list ───────────────────────────────────────────
              Text(
                'YOUR PROFILES',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 1.h),

              ...profiles.map((profile) => _ProfileTile(
                    profile: profile,
                    isActive: profile.id == active?.id,
                    onSwitch: () async {
                      if (profile.id == active?.id) {
                        Navigator.pop(context);
                        return;
                      }
                      final txProvider =
                          context.read<TransactionProvider>();
                      await profileProvider.switchProfile(
                        profile,
                        onSwitched: txProvider.reinitialize,
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    onRename: () => _showRenameDialog(
                      context,
                      profileProvider,
                      profile,
                    ),
                    onDelete: () => _showDeleteConfirm(
                      context,
                      profileProvider,
                      profile,
                      isActive: profile.id == active?.id,
                    ),
                  )),

              SizedBox(height: 2.h),

              // ── Error message ──────────────────────────────────────────
              if (profileProvider.errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 1.5.h),
                  child: Text(
                    profileProvider.errorMessage!,
                    style: TextStyle(
                        color: theme.colorScheme.error, fontSize: 13.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Profile'),
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Profile'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Business, Personal…',
            prefixIcon: Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              await context.read<ProfileProvider>().createProfile(name);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    ProfileProvider provider,
    AppProfile profile,
  ) {
    final controller = TextEditingController(text: profile.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Profile'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.edit_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              await provider.renameProfile(profile, name);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    ProfileProvider provider,
    AppProfile profile, {
    required bool isActive,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${profile.name}"?',
            ),
            const SizedBox(height: 12),
            const Text(
              'Note: The data file for this profile will remain on your device but will no longer appear in the app.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (isActive)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'You will be switched to another profile after deletion.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final txProvider = context.read<TransactionProvider>();
              final profileProvider = context.read<ProfileProvider>();

              final success =
                  await profileProvider.deleteProfile(profile);

              if (success && isActive && context.mounted) {
                // Switch to the new default profile (set by ProfileService).
                final remaining = profileProvider.profiles;
                if (remaining.isNotEmpty) {
                  await profileProvider.switchProfile(
                    remaining.first,
                    onSwitched: txProvider.reinitialize,
                  );
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: theme.colorScheme.primary, size: 20),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'Each profile has completely isolated transactions, customers, and balances. Switch anytime.',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final AppProfile profile;
  final bool isActive;
  final VoidCallback onSwitch;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _ProfileTile({
    required this.profile,
    required this.isActive,
    required this.onSwitch,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 1.5.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        leading: CircleAvatar(
          backgroundColor: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Text(
            profile.name.isNotEmpty
                ? profile.name[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          profile.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        subtitle: Text(
          isActive ? '● Active' : 'Tap to switch',
          style: TextStyle(
            fontSize: 12.sp,
            color: isActive
                ? theme.colorScheme.primary
                : theme.hintColor,
            fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Icon(Icons.check_circle,
                  color: theme.colorScheme.primary, size: 22),
            if (!isActive)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Rename',
                onPressed: onRename,
              ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: theme.colorScheme.error),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onSwitch,
      ),
    );
  }
}
