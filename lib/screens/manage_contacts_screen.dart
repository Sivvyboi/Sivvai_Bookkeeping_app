import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/local_customer.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/size_config.dart';
import '../widgets/themed_dialogs.dart';

class ManageContactsScreen extends StatelessWidget {
  const ManageContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final canPop = Navigator.canPop(context);

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                      'Manage Contacts',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.person_add_alt_1_outlined, color: theme.colorScheme.primary, size: 24),
                  onPressed: () => _importFromContacts(context, provider),
                  tooltip: 'Import from Phone',
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<LocalCustomer>>(
              stream: provider.watchCustomers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final customers = snapshot.data ?? [];

                if (customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64.sp, color: theme.dividerColor),
                        SizedBox(height: 16.h),
                        Text('No contacts found.', style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 4.h),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return _ContactListTile(customer: customer);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromContacts(BuildContext context, TransactionProvider provider) async {
    final permission = await Permission.contacts.request();
    if (permission.isGranted) {
      final contact = await FlutterContacts.native.showPicker();
      if (contact != null && context.mounted) {
        final name = contact.displayName ?? '';
        final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';

        // Default to DEBTOR for new imports
        await provider.addCustomer(name, phone: phone, relationType: 'DEBTOR');

        if (context.mounted) {
          ThemedDialogs.showSuccessSnackBar(context, 'Imported $name successfully.');
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission denied')),
        );
      }
    }
  }
}

class _ContactListTile extends StatelessWidget {
  final LocalCustomer customer;
  const _ContactListTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    final isDebtor = customer.relationType == 'DEBTOR';
    final accentColor = isDebtor
        ? (statusColors.debt ?? Colors.orange)
        : (statusColors.outflow ?? Colors.red);

    return Dismissible(
      key: Key('contact_${customer.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final detail =
            'Contact: ${customer.fullName}\n'
            'Outstanding ledger balance: ${SizeConfig.formatCompactCurrency(customer.totalDebtAmount)}\n\n'
            'Transaction history will be kept for accounting accuracy, '
            'but the ledger balance for this contact will be removed.';
        return await ThemedDialogs.showDeleteConfirmation(
          context,
          itemType: 'contact',
          detail: detail,
        );
      },
      onDismissed: (_) async {
        await provider.deleteCustomer(customer.id);
        if (context.mounted) {
          ThemedDialogs.showSuccessSnackBar(context, '${customer.fullName} removed from contacts.');
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 5.w),
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Card(
        margin: EdgeInsets.only(bottom: 2.h),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
          leading: CircleAvatar(
            backgroundColor: accentColor.withValues(alpha: 0.12),
            child: Text(
              customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : '?',
              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(customer.fullName, style: theme.textTheme.titleMedium),
          subtitle: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${isDebtor ? "Owes you" : "You owe"} ${SizeConfig.formatCompactCurrency(customer.totalDebtAmount)}',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                onPressed: () => _showEditDialog(context, provider, customer),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                onPressed: () => _confirmDelete(context, provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TransactionProvider provider) async {
    final detail =
        'Contact: ${customer.fullName}\n'
        'Outstanding ledger balance: ${SizeConfig.formatCompactCurrency(customer.totalDebtAmount)}\n\n'
        'Transaction history will be kept for accounting accuracy, '
        'but the ledger balance for this contact will be removed.';

    final confirmed = await ThemedDialogs.showDeleteConfirmation(
      context,
      itemType: 'contact',
      detail: detail,
    );
    if (confirmed == true && context.mounted) {
      await provider.deleteCustomer(customer.id);
      if (context.mounted) {
        ThemedDialogs.showSuccessSnackBar(context, '${customer.fullName} removed from contacts.');
      }
    }
  }

  void _showEditDialog(BuildContext context, TransactionProvider provider, LocalCustomer customer) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: customer.fullName);
    final phoneController = TextEditingController(text: customer.phoneNumber ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Edit Contact',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                customer.fullName = nameController.text.trim();
                customer.phoneNumber = phoneController.text.trim();
                await provider.updateCustomer(customer);
                await provider.refreshData();
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
