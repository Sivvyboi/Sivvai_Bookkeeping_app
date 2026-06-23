import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../utils/size_config.dart';
import 'add_transaction_screen.dart';
import 'debt_ledger_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Bookkeeper Dashboard', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.setSp(20))),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showBackupDialog(context),
            tooltip: 'Backup & Restore',
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(context, provider, currencyFormat),
                _buildQuickActions(context),
                
                // Date Range Filters
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth(4)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDateChip(provider, 'All', TransactionDateFilter.allTime),
                        SizedBox(width: SizeConfig.blockWidth(2)),
                        _buildDateChip(provider, 'Today', TransactionDateFilter.today),
                        SizedBox(width: SizeConfig.blockWidth(2)),
                        _buildDateChip(provider, 'This Week', TransactionDateFilter.thisWeek),
                        SizedBox(width: SizeConfig.blockWidth(2)),
                        _buildDateChip(provider, 'This Month', TransactionDateFilter.thisMonth),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: SizeConfig.blockHeight(1.5)),
                
                // Transaction Type Filters
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth(4)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: SizeConfig.setSp(18), 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      PopupMenuButton<TransactionTypeFilter>(
                        initialValue: provider.typeFilter,
                        icon: const Icon(Icons.filter_list, color: Colors.indigo),
                        onSelected: provider.setTypeFilter,
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: TransactionTypeFilter.all, child: Text('Show All')),
                          const PopupMenuItem(value: TransactionTypeFilter.sales, child: Text('Sales Only')),
                          const PopupMenuItem(value: TransactionTypeFilter.expenses, child: Text('Expenses Only')),
                          const PopupMenuItem(value: TransactionTypeFilter.debts, child: Text('Debts & Payments')),
                        ],
                      ),
                    ],
                  ),
                ),

                _buildTransactionList(provider, currencyFormat),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateChip(TransactionProvider provider, String label, TransactionDateFilter filter) {
    final isSelected = provider.dateFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => provider.setDateFilter(filter),
      selectedColor: Colors.indigo,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontSize: SizeConfig.setSp(12),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Backup & Restore'),
        content: const Text('Keep your data safe by exporting a backup file or restore from a previous one.'),
        actions: [
          ListTile(
            leading: const Icon(Icons.share, color: Colors.indigo),
            title: const Text('Export Backup'),
            subtitle: const Text('Share backup file to WhatsApp/Email'),
            onTap: () async {
              Navigator.pop(context);
              final success = await context.read<TransactionProvider>().exportData();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup exported successfully!')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file, color: Colors.orange),
            title: const Text('Restore from Backup'),
            subtitle: const Text('Upload a previously saved .json file'),
            onTap: () async {
              Navigator.pop(context);
              final success = await context.read<TransactionProvider>().importData();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data restored successfully!')),
                );
              } else if (context.mounted && context.read<TransactionProvider>().errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.read<TransactionProvider>().errorMessage!)),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete All Data', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Wipe all transactions and customers'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to permanently delete all your data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<TransactionProvider>().deleteAllData();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been wiped.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, TransactionProvider provider, NumberFormat format) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConfig.blockWidth(5)),
      decoration: const BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Cash in Hand',
            style: TextStyle(color: Colors.white70, fontSize: SizeConfig.setSp(14)),
          ),
          SizedBox(height: SizeConfig.blockHeight(0.5)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              format.format(provider.cashBalance),
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.setSp(36),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: SizeConfig.blockHeight(3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallSummary('Sales', provider.totalSales, Colors.greenAccent, format),
              _buildSmallSummary('Expenses', provider.totalExpenses, Colors.redAccent.shade100, format),
              _buildSmallSummary('Debt', provider.totalDebts, Colors.orangeAccent, format),
            ],
          ),
          SizedBox(height: SizeConfig.blockHeight(1)),
        ],
      ),
    );
  }

  Widget _buildSmallSummary(String label, double amount, Color color, NumberFormat format) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: SizeConfig.setSp(12))),
        SizedBox(height: SizeConfig.blockHeight(0.5)),
        Text(
          format.format(amount),
          style: TextStyle(color: color, fontSize: SizeConfig.setSp(15), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.blockWidth(4)),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                );
              },
              icon: Icon(Icons.add, size: SizeConfig.setSp(20)),
              label: Text('Add Transaction', style: TextStyle(fontSize: SizeConfig.setSp(14))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight(1.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(width: SizeConfig.blockWidth(3)),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DebtLedgerScreen()),
                );
              },
              icon: Icon(Icons.menu_book, size: SizeConfig.setSp(20)),
              label: Text('Debt Ledger', style: TextStyle(fontSize: SizeConfig.setSp(14))),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.indigo,
                side: const BorderSide(color: Colors.indigo),
                padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight(1.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(TransactionProvider provider, NumberFormat format) {
    final list = provider.transactions;

    if (list.isEmpty) {
      String message = 'No transactions found.';
      IconData icon = Icons.receipt_long;

      if (provider.dateFilter == TransactionDateFilter.today) {
        message = 'No transactions recorded yet today.';
        icon = Icons.today;
      }

      switch (provider.typeFilter) {
        case TransactionTypeFilter.sales:
          message = 'No sales recorded for this period.';
          icon = Icons.trending_up;
          break;
        case TransactionTypeFilter.expenses:
          message = 'No expenses recorded for this period.';
          icon = Icons.trending_down;
          break;
        case TransactionTypeFilter.debts:
          message = 'No credit or payment transactions.';
          icon = Icons.people_outline;
          break;
        default:
          break;
      }

      return Container(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight(5)),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: SizeConfig.blockWidth(15), color: Colors.grey.shade300),
            SizedBox(height: SizeConfig.blockHeight(2)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: SizeConfig.setSp(16)),
            ),
            SizedBox(height: SizeConfig.blockHeight(1)),
            TextButton(
              onPressed: () {
                provider.setTypeFilter(TransactionTypeFilter.all);
                provider.setDateFilter(TransactionDateFilter.allTime);
              },
              child: const Text('Clear All Filters'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth(4)),
      itemBuilder: (context, index) {
        final tx = list[index];
        final isOutflow = tx.transactionType == 'OUTFLOW';
        final isPayment = tx.transactionType == 'PAYMENT';
        
        bool isCashOut = isOutflow;
        if (isPayment && tx.customer.value != null) {
          isCashOut = tx.customer.value!.relationType == 'CREDITOR';
        }

        Color amountColor = isCashOut ? Colors.red : Colors.green;
        String prefix = isCashOut ? '- ' : '+ ';
        
        if (tx.isCredit) {
           amountColor = Colors.orange.shade700;
           prefix = ''; 
        }

        return Card(
          margin: EdgeInsets.only(bottom: SizeConfig.blockHeight(1.5)),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: amountColor.withValues(alpha: 0.1),
              child: Icon(
                isCashOut ? Icons.arrow_upward : Icons.arrow_downward,
                color: amountColor,
                size: SizeConfig.setSp(20),
              ),
            ),
            title: Text(
              tx.remarks?.isNotEmpty == true ? tx.remarks! : (isPayment ? 'Debt Payment' : (isOutflow ? 'Expense' : 'Sale')),
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: SizeConfig.setSp(14)),
            ),
            subtitle: Text(
              '${DateFormat('MMM dd • hh:mm a').format(tx.timestamp)}${tx.isCredit ? ' (Credit)' : ''}',
              style: TextStyle(fontSize: SizeConfig.setSp(12)),
            ),
            trailing: Text(
              prefix + format.format(tx.amount),
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.setSp(15),
              ),
            ),
          ),
        );
      },
    );
  }
}
