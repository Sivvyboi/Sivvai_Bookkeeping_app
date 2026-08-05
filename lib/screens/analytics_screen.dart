import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../utils/size_config.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<TransactionProvider>(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Seamless Custom Top Header ──────
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 12,
              left: 4.w,
              right: 4.w,
              bottom: 1.5.h,
            ),
            child: Row(
              children: [
                Text(
                  'Financial Analytics',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cash Flow Summary', style: theme.textTheme.titleLarge),
                  SizedBox(height: 2.h),
                  _buildBarChart(context, provider),
                  SizedBox(height: 4.h),
                  Text('Expense Breakdown', style: theme.textTheme.titleLarge),
                  SizedBox(height: 2.h),
                  _buildPieChart(context, provider),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, TransactionProvider provider) {
    final theme = Theme.of(context);
    return Container(
      height: 30.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: provider.totalSales > provider.totalExpenses ? provider.totalSales * 1.2 : provider.totalExpenses * 1.2,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: provider.totalSales,
                  color: Colors.green,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: provider.totalExpenses,
                  color: Colors.red,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const Text('Sales');
                  if (value == 1) return const Text('Expenses');
                  return const Text('');
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, TransactionProvider provider) {
    final theme = Theme.of(context);
    final transactions = provider.transactions.where((t) => t.transactionType == 'OUTFLOW').toList();
    
    // Group by remarks as a simple category fallback
    final Map<String, double> categories = {};
    for (var t in transactions) {
      final key = t.remarks?.isNotEmpty == true ? t.remarks! : 'General';
      categories[key] = (categories[key] ?? 0) + t.amount;
    }

    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: const Text('No expense data to display'),
        ),
      );
    }

    final List<PieChartSectionData> sections = [];
    int i = 0;
    final colors = [Colors.blue, Colors.orange, Colors.purple, Colors.teal, Colors.red];
    
    categories.forEach((name, amount) {
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: amount,
          title: '${((amount / provider.totalExpenses) * 100).toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      i++;
    });

    return Container(
      height: 30.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories.entries.take(5).map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, color: colors[categories.keys.toList().indexOf(e.key) % colors.length]),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.key, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
