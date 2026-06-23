import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/transaction_provider.dart';
import '../models/local_customer.dart';
import '../widgets/repayment_dialog.dart';
import '../utils/size_config.dart';
import 'customer_transactions_screen.dart';

class DebtLedgerScreen extends StatelessWidget {
  const DebtLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text('Ledger Management', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)),
          backgroundColor: Colors.indigo.shade800,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.sp),
            tabs: const [
              Tab(text: 'Money to Collect'),
              Tab(text: 'Money to Pay'),
            ],
          ),
        ),
        body: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                _buildDebtorTab(context, provider, currencyFormat),
                _buildCreditorTab(context, provider, currencyFormat),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDebtorTab(BuildContext context, TransactionProvider provider, NumberFormat format) {
    final debtors = provider.debtors;
    return Column(
      children: [
        _buildSummaryHeader(
          'Total Owed to You', 
          provider.totalOwedToYou, 
          Colors.amber.shade800, 
          Colors.green.shade700,
          format,
          Icons.arrow_downward,
        ),
        Expanded(
          child: debtors.isEmpty
              ? _buildEmptyState('No debtors found.', Icons.check_circle_outline, Colors.green)
              : _buildContactList(context, debtors, Colors.amber.shade800, format),
        ),
      ],
    );
  }

  Widget _buildCreditorTab(BuildContext context, TransactionProvider provider, NumberFormat format) {
    final creditors = provider.creditors;
    return Column(
      children: [
        _buildSummaryHeader(
          'Total You Owe', 
          provider.totalYouOwe, 
          const Color(0xFFDC143C), // Crimson
          Colors.red.shade800,
          format,
          Icons.arrow_upward,
        ),
        Expanded(
          child: creditors.isEmpty
              ? _buildEmptyState('No creditors found.', Icons.thumb_up_alt_outlined, Colors.blue)
              : _buildContactList(context, creditors, const Color(0xFFDC143C), format),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(String label, double amount, Color primaryColor, Color secondaryColor, NumberFormat format, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withValues(alpha: 0.1), secondaryColor.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(bottom: BorderSide(color: primaryColor.withValues(alpha: 0.2), width: 1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.sp, color: primaryColor),
              SizedBox(width: 2.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.sp, 
                  color: primaryColor, 
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              format.format(amount),
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w900,
                color: primaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, Color color) {
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
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList(BuildContext context, List<LocalCustomer> contacts, Color accentColor, NumberFormat format) {
    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: contacts.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
      itemBuilder: (context, index) {
        final customer = contacts[index];
        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.w),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            onTap: () => _showContactOptions(context, customer, format),
            borderRadius: BorderRadius.circular(4.w),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 6.w,
                    backgroundColor: accentColor.withValues(alpha: 0.1),
                    child: Text(
                      customer.fullName[0].toUpperCase(),
                      style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          customer.fullName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 12.sp, color: Colors.grey.shade600),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                customer.phoneNumber?.isNotEmpty == true ? customer.phoneNumber! : 'No phone',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  format.format(customer.totalDebtAmount),
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                              Text(
                                'BALANCE',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2.w),
                        IconButton(
                          icon: Icon(Icons.check_circle_outline, color: accentColor, size: 24.sp),
                          onPressed: () => _showRepaymentDialog(context, customer),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Settle',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRepaymentDialog(BuildContext context, LocalCustomer customer) async {
    final format = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => RepaymentDialog(customer: customer),
    );

    if (amount != null && amount > 0 && context.mounted) {
      await context.read<TransactionProvider>().settleLedgerBalance(
        customerId: customer.id,
        amountPaid: amount,
        isCreditor: customer.relationType == 'CREDITOR',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${format.format(amount)} repayment recorded successfully'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    }
  }

  void _showContactOptions(BuildContext context, LocalCustomer customer, NumberFormat format) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isDebtor = customer.relationType == 'DEBTOR';
        Color accent = isDebtor ? Colors.amber.shade800 : const Color(0xFFDC143C);
        
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(
            8.w,
            2.h,
            8.w,
            4.h + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                margin: EdgeInsets.only(bottom: 3.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                customer.fullName,
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${isDebtor ? "Owed to you" : "You owe"}: ${format.format(customer.totalDebtAmount)}',
                  style: TextStyle(
                    fontSize: 16.sp, 
                    color: accent, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              _buildOptionTile(
                icon: Icons.payments_outlined,
                title: 'Settle Balance',
                color: accent,
                onTap: () {
                  Navigator.pop(context);
                  _showRepaymentDialog(context, customer);
                },
              ),
              _buildOptionTile(
                icon: Icons.history,
                title: 'Transaction History',
                color: Colors.indigo,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CustomerTransactionsScreen(customer: customer)),
                  );
                },
              ),
              if (isDebtor) 
                _buildOptionTile(
                  icon: Icons.message_outlined,
                  title: 'Send WhatsApp Reminder',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    Navigator.pop(context);
                    _shareReminder(customer, format);
                  },
                ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24.sp),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
      trailing: Icon(Icons.chevron_right, size: 16.sp),
      onTap: onTap,
    );
  }

  void _shareReminder(LocalCustomer customer, NumberFormat format) async {
    const storeName = "the merchant"; 
    final message = "Hello ${customer.fullName}, this is a friendly reminder regarding your outstanding balance of ${format.format(customer.totalDebtAmount)} with $storeName. Kindly make arrangements for payment. Thank you!";
    
    if (customer.phoneNumber?.isNotEmpty == true) {
      final whatsappUrl = Uri.parse("whatsapp://send?phone=${customer.phoneNumber}&text=${Uri.encodeComponent(message)}");
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
        return;
      }
    }
    Share.share(message, subject: 'Payment Reminder');
  }
}
