import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/size_config.dart';
import '../widgets/responsive_value_text.dart';
import 'settings_screen.dart';
import 'global_history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic status bar overlay depending on dark/light mode
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // No AppBar — full edge-to-edge layout
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // ── Top Zone (Header controls + Floating Gradient Card) ──────
              _buildTopZone(context, provider, currencyFormat, statusColors, isDark),

              // ── Scrollable Lower Content ────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => provider.refreshData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.only(top: 2.h, bottom: 14.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Filter Chips Row
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildDateChip(provider, 'All',        TransactionDateFilter.allTime),
                                SizedBox(width: 2.5.w),
                                _buildDateChip(provider, 'Today',      TransactionDateFilter.today),
                                SizedBox(width: 2.5.w),
                                _buildDateChip(provider, 'This Week',  TransactionDateFilter.thisWeek),
                                SizedBox(width: 2.5.w),
                                _buildDateChip(provider, 'This Month', TransactionDateFilter.thisMonth),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 2.5.h),

                        // Recent Transactions header
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Transactions',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PopupMenuButton<TransactionTypeFilter>(
                                initialValue: provider.typeFilter,
                                icon: Icon(Icons.filter_list, color: theme.colorScheme.primary),
                                onSelected: provider.setTypeFilter,
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: TransactionTypeFilter.all,      child: Text('Show All')),
                                  const PopupMenuItem(value: TransactionTypeFilter.sales,    child: Text('Sales Only')),
                                  const PopupMenuItem(value: TransactionTypeFilter.expenses, child: Text('Expenses Only')),
                                  const PopupMenuItem(value: TransactionTypeFilter.debts,    child: Text('Debts & Payments')),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 1.h),

                        HomeTransactionHistoryList(
                          transactions: provider.transactions,
                          currencyFormat: currencyFormat,
                          statusColors: statusColors,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Top Zone: Header controls on pure white/dark canvas + Floating Gradient Summary Card ──

  Widget _buildTopZone(
    BuildContext context,
    TransactionProvider provider,
    NumberFormat format,
    StatusColors statusColors,
    bool isDark,
  ) {
    Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: Colors.transparent, // Edge-to-edge scaffold canvas background shows through cleanly
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status-bar-height spacer + pill row ──
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 8,
              left: 4.w,
              right: 4.w,
              bottom: 2.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profiles pill button (left-aligned)
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, _) {
                    final name = profileProvider.activeProfile?.name ?? 'Personal';
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isDark ? Colors.white30 : Colors.black12,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Settings icon (right)
                IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
          ),

          // ── Floating Logo-Inspired Gradient Summary Card ──
          Padding(
            padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 2.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
              decoration: BoxDecoration(
                // Diagonal brand gradient from top-right (emerald green) to cyan to deep blue
                gradient: statusColors.dashboardGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withValues(alpha: isDark ? 0.35 : 0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Cash in Hand',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.6.h),
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
                  SizedBox(height: 2.5.h),
                  // Translucent White Divider line
                  Divider(color: Colors.white.withValues(alpha: 0.25), thickness: 1),
                  SizedBox(height: 1.5.h),
                  // Sales | Expenses | Debt row with high contrast white text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryColumn('Sales',    provider.totalSales,    Colors.white, format),
                      _buildDividerDot(),
                      _buildSummaryColumn('Expenses', provider.totalExpenses, Colors.white, format),
                      _buildDividerDot(),
                      _buildSummaryColumn('Debt',     provider.totalDebts,    Colors.white, format),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, double amount, Color color, NumberFormat format) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white60, fontSize: 11.sp)),
        SizedBox(height: 0.5.h),
        ResponsiveValueText(
          amount: amount,
          label: label,
          style: TextStyle(color: color, fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDividerDot() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildDateChip(TransactionProvider provider, String label, TransactionDateFilter filter) {
    final isSelected = provider.dateFilter == filter;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: (_) => provider.setDateFilter(filter),
    );
  }
}

// ── Transaction History List ──────────────────────────────────────────────────

class HomeTransactionHistoryList extends StatelessWidget {
  final List<dynamic> transactions;
  final NumberFormat currencyFormat;
  final StatusColors statusColors;

  const HomeTransactionHistoryList({
    super.key,
    required this.transactions,
    required this.currencyFormat,
    required this.statusColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 12.w, color: theme.dividerTheme.color),
              SizedBox(height: 2.h),
              Text(
                'No transactions found.',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
      );
    }

    final displayCount = transactions.length > 10 ? 10 : transactions.length;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayCount,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemBuilder: (context, index) {
        final tx = transactions[index];

        final isOutflow  = tx.transactionType == 'OUTFLOW';
        final isPayment  = tx.transactionType == 'PAYMENT' ||
                           tx.transactionType == 'PAYMENT_OUT' ||
                           tx.transactionType == 'PAYMENT_IN';
        final isPayOut   = tx.transactionType == 'PAYMENT_OUT';
        final isCashOut  = isOutflow || isPayOut;

        Color amountColor = isCashOut ? statusColors.outflow! : statusColors.inflow!;
        if (tx.isCredit) amountColor = statusColors.debt!;

        String txLabel = tx.remarks?.isNotEmpty == true
            ? tx.remarks!
            : (isPayment ? 'Debt Payment' : (isOutflow ? 'Expense' : 'Sale'));

        return Dismissible(
          key: Key('tx_${tx.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 5.w),
            margin: EdgeInsets.only(bottom: 1.5.h),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) => context.read<TransactionProvider>().deleteTransaction(tx.id),
          child: Card(
            elevation: 1,
            margin: EdgeInsets.only(bottom: 1.5.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GlobalHistoryScreen(scrollToTransactionId: tx.id),
                ),
              ),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: amountColor.withValues(alpha: 0.12),
                child: Icon(
                  isCashOut ? Icons.arrow_upward : Icons.arrow_downward,
                  color: amountColor,
                  size: 20,
                ),
              ),
              title: Text(txLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                DateFormat('MMM dd • hh:mm a').format(tx.timestamp),
                style: TextStyle(fontSize: 12.sp),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isCashOut ? "- " : "+ "}${currencyFormat.format(tx.amount)}',
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Icon(Icons.chevron_right, size: 18.sp, color: theme.hintColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
