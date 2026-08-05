import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'analytics_screen.dart';
import 'debt_ledger_screen.dart';
import 'settings_screen.dart';
import 'add_transaction_screen.dart';
import '../utils/size_config.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final List<Widget> _screens = const [
    HomeScreen(),
    AnalyticsScreen(),
    DebtLedgerScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Continuous soft pulse glow animation for center FAB
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 4.0, end: 16.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _openAddTransactionModal() {
    AddTransactionScreen.showModal(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF10B981), // Emerald green
                  Color(0xFF06B6D4), // Bright cyan
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.45),
                  blurRadius: _glowAnimation.value * 1.5,
                  spreadRadius: _glowAnimation.value * 0.4,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: _openAddTransactionModal,
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                size: 34,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          border: isDark
              ? null
              : Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10.0,
          elevation: 0,
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Left items (Dashboard, Analytics)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
                      _buildNavItem(1, Icons.bar_chart_outlined, Icons.bar_chart, 'Analytics'),
                    ],
                  ),
                ),
                // Notch gap for center FAB
                const SizedBox(width: 72),
                // Right items (Ledger, Settings)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(2, Icons.menu_book_outlined, Icons.menu_book, 'Ledger'),
                      _buildNavItem(3, Icons.settings_outlined,  Icons.settings,  'Settings'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : (theme.brightness == Brightness.dark ? Colors.white54 : Colors.black45);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
