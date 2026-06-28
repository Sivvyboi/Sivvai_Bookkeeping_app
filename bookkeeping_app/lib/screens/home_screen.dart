import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/size_config.dart';
import '../widgets/responsive_value_text.dart';
import 'add_transaction_screen.dart';
import 'debt_ledger_screen.dart';
import 'settings_screen.dart';
import 'global_history_screen.dart';
import 'package:sivvai_bookkeeper/adaptive_brand_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Bookkeeper Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async => await provider.refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                // --- FIXED CORRUPTED TYPO HERE ---
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(
                    context,
                    provider,
                    currencyFormat,
                    statusColors,
                  ),
                  _buildQuickActions(context, theme),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildDateChip(
                            provider,
                            'All',
                            TransactionDateFilter.allTime,
                          ),
                          SizedBox(width: 2.w),
                          _buildDateChip(
                            provider,
                            'Today',
                            TransactionDateFilter.today,
                          ),
                          SizedBox(width: 2.w),
                          _buildDateChip(
                            provider,
                            'This Week',
                            TransactionDateFilter.thisWeek,
                          ),
                          SizedBox(width: 2.w),
                          _buildDateChip(
                            provider,
                            'This Month',
                            TransactionDateFilter.thisMonth,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 1.5.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18.sp,
                          ),
                        ),
                        PopupMenuButton<TransactionTypeFilter>(
                          initialValue: provider.typeFilter,
                          icon: Icon(
                            Icons.filter_list,
                            color: theme.colorScheme.primary,
                          ),
                          onSelected: provider.setTypeFilter,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: TransactionTypeFilter.all,
                              child: Text('Show All'),
                            ),
                            const PopupMenuItem(
                              value: TransactionTypeFilter.sales,
                              child: Text('Sales Only'),
                            ),
                            const PopupMenuItem(
                              value: TransactionTypeFilter.expenses,
                              child: Text('Expenses Only'),
                            ),
                            const PopupMenuItem(
                              value: TransactionTypeFilter.debts,
                              child: Text('Debts & Payments'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  HomeTransactionHistoryList(
                    transactions: provider.transactions,
                    currencyFormat: currencyFormat,
                    statusColors: statusColors,
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateChip(
    TransactionProvider provider,
    String label,
    TransactionDateFilter filter,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: provider.dateFilter == filter,
      onSelected: (_) => provider.setDateFilter(filter),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    TransactionProvider provider,
    NumberFormat format,
    StatusColors statusColors,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: statusColors.dashboardGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        children: [
          const Text('Cash in Hand', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 0.5.h),
          ResponsiveValueText(
            amount: provider.cashBalance,
            label: 'Cash in Hand',
            compactByDefault: false,
            style: TextStyle(
              color: Colors.white,
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallSummary(
                'Sales',
                provider.totalSales,
                statusColors.onDashboardInflow!,
                format,
              ),
              _buildSmallSummary(
                'Expenses',
                provider.totalExpenses,
                statusColors.onDashboardOutflow!,
                format,
              ),
              _buildSmallSummary(
                'Debt',
                provider.totalDebts,
                statusColors.onDashboardDebt!,
                format,
              ),
            ],
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  Widget _buildSmallSummary(
    String label,
    double amount,
    Color color,
    NumberFormat format,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 12.sp),
        ),
        SizedBox(height: 0.5.h),
        ResponsiveValueText(
          amount: amount,
          label: label,
          style: TextStyle(
            color: color,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DebtLedgerScreen(),
                ),
              ),
              icon: const Icon(Icons.menu_book),
              label: const Text('Debt Ledger'),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeTransactionHistoryList extends StatefulWidget {
  final List<dynamic> transactions;
  final NumberFormat currencyFormat;
  final StatusColors statusColors;

  // ignore: use_super_parameters
  const HomeTransactionHistoryList({
    // ignore: strict_top_level_inference
    key,
    required this.transactions,
    required this.currencyFormat,
    required this.statusColors,
  }) : super(key: key);

  @override
  State<HomeTransactionHistoryList> createState() =>
      _HomeTransactionHistoryListState();
}

class _HomeTransactionHistoryListState
    extends State<HomeTransactionHistoryList> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 12.w,
                color: theme.dividerTheme.color,
              ),
              SizedBox(height: 2.h),
              Text(
                'No transactions found.',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.transactions.length > 10
          ? 10
          : widget.transactions.length,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemBuilder: (context, index) {
        final tx = widget.transactions[index];

        return FutureBuilder<void>(
          future: tx.customer.load(),
          builder: (context, _) {
            final isOutflow = tx.transactionType == 'OUTFLOW';
            final isPayment = tx.transactionType == 'PAYMENT';

            bool isCashOut = isOutflow;
            if (isPayment && tx.customer.value != null) {
              isCashOut = tx.customer.value!.relationType == 'CREDITOR';
            }

            Color amountColor = isCashOut
                ? widget.statusColors.outflow!
                : widget.statusColors.inflow!;
            if (tx.isCredit) amountColor = widget.statusColors.debt!;

            return Card(
              margin: EdgeInsets.only(bottom: 1.5.h),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GlobalHistoryScreen(scrollToTransactionId: tx.id),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: amountColor.withValues(alpha: 0.1),
                  child: Icon(
                    isCashOut ? Icons.arrow_upward : Icons.arrow_downward,
                    color: amountColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  tx.remarks?.isNotEmpty == true
                      ? tx.remarks!
                      : (isPayment
                            ? 'Debt Payment'
                            : (isOutflow ? 'Expense' : 'Sale')),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  DateFormat('MMM dd • hh:mm a').format(tx.timestamp),
                  style: TextStyle(fontSize: 12.sp),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (isCashOut ? '- ' : '+ ') +
                          widget.currencyFormat.format(tx.amount),
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.chevron_right,
                      size: 16.sp,
                      color: theme.hintColor,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Automatically flips matching light or dark system styles seamlessly
            AdaptiveBrandLogo(width: 50.w, height: 50.w),
            SizedBox(height: 2.h),
            Text(
              'Sivvai Bookkeeper',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
