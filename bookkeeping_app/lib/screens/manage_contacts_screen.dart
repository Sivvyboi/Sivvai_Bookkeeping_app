import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/local_customer.dart';
import '../providers/transaction_provider.dart';
import '../utils/size_config.dart';

class ManageContactsScreen extends StatelessWidget {
  const ManageContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Manage Contacts')),
      body: StreamBuilder<List<LocalCustomer>>(
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
            padding: EdgeInsets.all(16.w),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return _ContactListTile(customer: customer);
            },
          );
        },
      ),
    );
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
      margin: EdgeInsets.only(bottom: 10.h),
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