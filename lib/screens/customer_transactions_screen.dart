import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/local_customer.dart';
import '../models/local_transaction.dart';
import '../services/database_service.dart';
import '../utils/size_config.dart';

class CustomerTransactionsScreen extends StatelessWidget {
  final LocalCustomer customer;

  const CustomerTransactionsScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final dbService = DatabaseService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer.fullName, 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(18))),
            Text(
              customer.relationType == 'DEBTOR' ? 'Debtor Ledger' : 'Creditor Ledger',
              style: TextStyle(fontSize: SizeConfig.setSp(12), fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildCustomerSummary(currencyFormat),
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
                      child: Text('No transaction history found.', 
                        style: TextStyle(fontSize: SizeConfig.setSp(14), color: Colors.grey)),
                    ),
                  );
                }

                final transactions = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(SizeConfig.blockWidth(4)),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return _buildTransactionTile(tx, currencyFormat, dateFormat);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSummary(NumberFormat format) {
    bool isDebtor = customer.relationType == 'DEBTOR';
    Color accentColor = isDebtor ? Colors.amber.shade800 : Colors.red.shade800;

    return Container(
      padding: EdgeInsets.all(SizeConfig.blockWidth(6)),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: accentColor.withValues(alpha: 0.1))),
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: SizeConfig.setSp(14)),
                ),
                SizedBox(height: SizeConfig.blockHeight(0.5)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    format.format(customer.totalDebtAmount),
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
            backgroundColor: accentColor.withValues(alpha: 0.1),
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

  Widget _buildTransactionTile(LocalTransaction tx, NumberFormat currencyFormat, DateFormat dateFormat) {
    bool isCredit = tx.isCredit;
    bool isPayment = tx.transactionType == 'PAYMENT';
    
    String label = tx.transactionType;
    if (isPayment) label = "Payment Received";
    if (isCredit && tx.transactionType == 'INFLOW') label = "Credit Sale";
    if (isCredit && tx.transactionType == 'OUTFLOW') label = "Credit Purchase";

    Color amountColor = tx.transactionType == 'INFLOW' ? Colors.green : (tx.transactionType == 'OUTFLOW' ? Colors.red : Colors.blue);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight(1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(14))),
              Text(
                (tx.transactionType == 'OUTFLOW' ? '- ' : '+ ') + currencyFormat.format(tx.amount),
                style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(14)),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.blockHeight(0.5)),
          if (tx.remarks != null && tx.remarks!.isNotEmpty)
            Text(tx.remarks!, style: TextStyle(fontSize: SizeConfig.setSp(13))),
          SizedBox(height: SizeConfig.blockHeight(0.5)),
          Text(dateFormat.format(tx.timestamp), 
            style: TextStyle(color: Colors.grey.shade500, fontSize: SizeConfig.setSp(11))),
        ],
      ),
    );
  }
}
