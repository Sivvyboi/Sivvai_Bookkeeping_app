import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/local_customer.dart';
import '../providers/transaction_provider.dart';
import '../utils/size_config.dart';

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
                  padding: EdgeInsets.all(16.w),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imported $name successfully')),
          );
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
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    return Card(
      margin: EdgeInsets.only(bottom: 2.h), // Fixed: Was 10.h which was huge
      child: ListTile(
        leading: CircleAvatar(
          child: Text(customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : '?'),
        ),
        title: Text(customer.fullName, style: theme.textTheme.titleMedium),
        subtitle: Text(
          'Balance: ${SizeConfig.formatCompactCurrency(customer.totalDebtAmount)} (${customer.relationType})',
          style: TextStyle(color: customer.relationType == 'DEBTOR' ? Colors.orange : Colors.red),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditDialog(context, provider, customer),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () => _confirmDelete(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TransactionProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact?'),
        content: const Text(
            'This will remove the contact profile but keep all transaction history for accounting accuracy.'
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await provider.deleteCustomer(customer.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, TransactionProvider provider, LocalCustomer customer) {
    final nameController = TextEditingController(text: customer.fullName);
    final phoneController = TextEditingController(text: customer.phoneNumber ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                customer.fullName = nameController.text.trim();
                customer.phoneNumber = phoneController.text.trim();
                await provider.updateCustomer(customer);
                await provider.refreshData(); // Forces stream layout synchronization
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
