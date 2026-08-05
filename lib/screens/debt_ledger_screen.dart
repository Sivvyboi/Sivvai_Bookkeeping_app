import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../models/local_customer.dart';
import '../widgets/repayment_dialog.dart';
import '../utils/size_config.dart';
import 'customer_transactions_screen.dart';
import 'global_history_screen.dart';
import 'manage_contacts_screen.dart';

class DebtLedgerScreen extends StatelessWidget {
  const DebtLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            // ── Seamless Custom Top Header ──────
            Padding(
              padding: EdgeInsets.only(
                top: topPadding + 8,
                left: 4.w,
                right: 2.w,
                bottom: 0.5.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ledger Management',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    onSelected: (value) {
                      if (value == 'history') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GlobalHistoryScreen()),
                        );
                      } else if (value == 'contacts') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageContactsScreen()),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'history',
                        child: Row(
                          children: [
                            Icon(Icons.history, color: Colors.black54),
                            SizedBox(width: 8),
                            Text('View Global History'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'contacts',
                        child: Row(
                          children: [
                            Icon(Icons.people_outline, color: Colors.black54),
                            SizedBox(width: 8),
                            Text('Manage Contacts'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TabBar(
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
              tabs: const [
                Tab(text: 'Money to Collect'),
                Tab(text: 'Money to Pay'),
              ],
            ),
            Expanded(
              child: Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  return TabBarView(
                    children: [
                      _buildDebtorTab(context, provider, currencyFormat, statusColors),
                      _buildCreditorTab(context, provider, currencyFormat, statusColors),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtorTab(BuildContext context, TransactionProvider provider, NumberFormat format, StatusColors status) {
    return Column(
      children: [
        _buildSummaryHeader('Total Owed to You', provider.totalOwedToYou, status.debt!, status.inflowGradient!, Icons.arrow_downward),
        Expanded(
          child: provider.debtors.isEmpty
              ? _buildEmptyState(context, 'No debtors found.', Icons.check_circle_outline, status.inflow!)
              : _buildContactList(context, provider.debtors, status.debt!, format),
        ),
      ],
    );
  }

  Widget _buildCreditorTab(BuildContext context, TransactionProvider provider, NumberFormat format, StatusColors status) {
    return Column(
      children: [
        _buildSummaryHeader('Total You Owe', provider.totalYouOwe, status.outflow!, status.outflowGradient!, Icons.arrow_upward),
        Expanded(
          child: provider.creditors.isEmpty
              ? _buildEmptyState(context, 'No creditors found.', Icons.thumb_up_alt_outlined, status.inflow!)
              : _buildContactList(context, provider.creditors, status.outflow!, format),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(String label, double amount, Color accent, Gradient gradient, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 6.w),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.sp, color: Colors.white70),
              SizedBox(width: 2.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.sp, 
                  color: Colors.white70, 
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              SizeConfig.formatCompactCurrency(amount),
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15.w, color: color.withValues(alpha: 0.3)),
            ),
            SizedBox(height: 3.h),
            Text(
              message,
              style: TextStyle(fontSize: 16.sp, color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList(BuildContext context, List<LocalCustomer> contacts, Color accent, NumberFormat format) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 4.h),
      itemCount: contacts.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
      itemBuilder: (context, index) {
        final customer = contacts[index];
        return Card(
          child: InkWell(
            onTap: () => _showContactOptions(context, customer, format),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 6.w,
                    backgroundColor: accent.withValues(alpha: 0.1),
                    child: Text(
                      customer.fullName[0].toUpperCase(),
                      style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.fullName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: theme.textTheme.bodyLarge?.color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 12.sp, color: theme.textTheme.bodyMedium?.color),
                            SizedBox(width: 1.w),
                            Text(
                              customer.phoneNumber?.isNotEmpty == true ? customer.phoneNumber! : 'No phone',
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        SizeConfig.formatCompactCurrency(customer.totalDebtAmount),
                        style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 16.sp),
                      ),
                      Text(
                        'BALANCE',
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: .4), fontSize: 10.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showContactOptions(BuildContext context, LocalCustomer customer, NumberFormat format) {
    final theme = Theme.of(context);
    final status = theme.extension<StatusColors>()!;
    final isDebtor = customer.relationType == 'DEBTOR';
    final accent = isDebtor ? status.debt! : status.outflow!;
    
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => Container(
        padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10.w, height: 4, margin: EdgeInsets.only(bottom: 2.h), decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
            Text(customer.fullName, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
              decoration: BoxDecoration(color: accent.withValues(alpha: .1), borderRadius: BorderRadius.circular(20)),
              child: Text(
                '${isDebtor ? "Owed to you" : "You owe"}: ${SizeConfig.formatCompactCurrency(customer.totalDebtAmount)}',
                style: TextStyle(fontSize: 14.sp, color: accent, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 3.h),
            _buildOptionTile(bottomSheetContext, Icons.payments_outlined, 'Settle Balance', accent, () {
              Navigator.pop(bottomSheetContext);
              _showRepaymentDialog(context, customer);
            }),
            _buildOptionTile(bottomSheetContext, Icons.history, 'Transaction History', theme.colorScheme.primary, () {
              Navigator.pop(bottomSheetContext);
              Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerTransactionsScreen(customer: customer)));
            }),
            _buildOptionTile(bottomSheetContext, Icons.edit_outlined, 'Edit Contact', Colors.blue, () {
              Navigator.pop(bottomSheetContext);
              _showEditDialog(context, customer);
            }),
            _buildOptionTile(bottomSheetContext, Icons.delete_outline, 'Delete Contact', Colors.red, () {
              Navigator.pop(bottomSheetContext);
              _confirmDelete(context, customer);
            }),
            if (isDebtor) _buildOptionTile(bottomSheetContext, Icons.message, 'Send WhatsApp Reminder', const Color(0xFF25D366), () {
              Navigator.pop(bottomSheetContext);
              _shareReminder(customer, format);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: theme.textTheme.bodyLarge?.color)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }

  Future<void> _showRepaymentDialog(BuildContext context, LocalCustomer customer) async {
    final amount = await showDialog<double>(context: context, builder: (context) => RepaymentDialog(customer: customer));
    if (amount != null && amount > 0 && context.mounted) {
      await context.read<TransactionProvider>().settleLedgerBalance(customerId: customer.id, amountPaid: amount, isCreditor: customer.relationType == 'CREDITOR');
    }
  }

  void _confirmDelete(BuildContext context, LocalCustomer customer) {
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
              final provider = context.read<TransactionProvider>();
              await provider.deleteCustomer(customer.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, LocalCustomer customer) {
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
              decoration: const InputDecoration(labelText: 'Phone Number (Optional)'),
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
                final provider = context.read<TransactionProvider>();
                await provider.updateCustomer(customer);
                await provider.refreshData();
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _shareReminder(LocalCustomer customer, NumberFormat format) async {
    final message = "Hello ${customer.fullName}, just a friendly reminder regarding your outstanding balance of ${format.format(customer.totalDebtAmount)}. Thank you!";
    if (customer.phoneNumber?.isNotEmpty == true) {
      final url = Uri.parse("whatsapp://send?phone=${customer.phoneNumber}&text=${Uri.encodeComponent(message)}");
      if (await canLaunchUrl(url)) { await launchUrl(url); return; }
    }
    Share.share(message);
  }
}
