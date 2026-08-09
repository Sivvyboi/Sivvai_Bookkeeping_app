import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/local_customer.dart';
import '../models/local_transaction.dart';
import '../services/database_service.dart';
import '../providers/theme_provider.dart';
import '../utils/size_config.dart';

class CustomerTransactionsScreen extends StatelessWidget {
  final LocalCustomer customer;

  const CustomerTransactionsScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final dbService = DatabaseService();
    final isDark = theme.brightness == Brightness.dark;
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
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 1.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      customer.relationType == 'DEBTOR' ? 'Debtor Ledger' : 'Creditor Ledger',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildCustomerSummary(context, statusColors),
                  StreamBuilder<List<LocalTransaction>>(
                    stream: dbService.watchCustomerTransactions(customer.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: EdgeInsets.only(top: SizeConfig.blockHeight(10)),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(top: SizeConfig.blockHeight(10)),
                          child: Center(
                            child: Text(
                              'No transaction history found.',
                              style: TextStyle(
                                fontSize: SizeConfig.setSp(14),
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        );
                      }

                      final transactions = snapshot.data!;
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(SizeConfig.blockWidth(4)),
                        itemCount: transactions.length,
                        separatorBuilder: (context, index) => Divider(color: theme.dividerColor),
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return _buildTransactionTile(context, tx, currencyFormat, dateFormat, statusColors);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSummary(BuildContext context, StatusColors statusColors) {
    final theme = Theme.of(context);
    bool isDebtor = customer.relationType == 'DEBTOR';
    Color accentColor = isDebtor ? statusColors.debt! : statusColors.outflow!;

    return Container(
      padding: EdgeInsets.all(SizeConfig.blockWidth(6)),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDebtor ? 'Total Balance Owed' : 'Total Balance You Owe',
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: SizeConfig.setSp(14)),
                ),
                SizedBox(height: SizeConfig.blockHeight(0.5)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    SizeConfig.formatCompactCurrency(customer.totalDebtAmount),
                    style: TextStyle(
                      fontSize: SizeConfig.setSp(24), 
                      fontWeight: FontWeight.bold, 
                      color: accentColor
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: SizeConfig.blockWidth(4)),
          CircleAvatar(
            radius: SizeConfig.blockWidth(7),
            backgroundColor: accentColor.withValues(alpha: .1),
            child: Icon(
              isDebtor ? Icons.arrow_downward : Icons.arrow_upward, 
              color: accentColor,
              size: SizeConfig.setSp(24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, LocalTransaction tx, NumberFormat currencyFormat, DateFormat dateFormat, StatusColors statusColors) {
    final theme = Theme.of(context);
    bool isCredit = tx.isCredit;
    bool isPayment = tx.transactionType == 'PAYMENT' ||
        tx.transactionType == 'PAYMENT_IN' ||
        tx.transactionType == 'PAYMENT_OUT';
    
    String label = tx.transactionType;
    if (tx.transactionType == 'PAYMENT_IN' || (isPayment && customer.relationType == 'DEBTOR')) {
      label = "Payment Received";
    } else if (tx.transactionType == 'PAYMENT_OUT' || (isPayment && customer.relationType == 'CREDITOR')) {
      label = "Payment Made";
    }
    if (isCredit && tx.transactionType == 'INFLOW') label = "Credit Sale";
    if (isCredit && tx.transactionType == 'OUTFLOW') label = "Credit Purchase";

    bool isCashOut = tx.transactionType == 'OUTFLOW' || tx.transactionType == 'PAYMENT_OUT';

    Color amountColor = isCashOut 
        ? statusColors.outflow! 
        : (tx.transactionType == 'INFLOW' || tx.transactionType == 'PAYMENT_IN' ? statusColors.inflow! : theme.colorScheme.primary);
    if (tx.isCredit) amountColor = statusColors.debt!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight(1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(14), color: theme.textTheme.bodyLarge?.color)),
              Text(
                (isCashOut ? '- ' : '+ ') + currencyFormat.format(tx.amount),
                style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(14)),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.blockHeight(0.5)),
          if (tx.remarks != null && tx.remarks!.isNotEmpty)
            Text(tx.remarks!, style: TextStyle(fontSize: SizeConfig.setSp(13), color: theme.textTheme.bodyMedium?.color)),
          SizedBox(height: SizeConfig.blockHeight(0.5)),
          Text(dateFormat.format(tx.timestamp), 
            style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: SizeConfig.setSp(11))),
        ],
      ),
    );
  }
}
