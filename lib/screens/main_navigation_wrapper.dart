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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final barColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Main screen content ───────────────────────────────────────────
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),

          // ── Floating bottom navigation bar ────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFloatingNavBar(theme, isDark, barColor, bottomPadding),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar(
    ThemeData theme,
    bool isDark,
    Color barColor,
    double bottomPadding,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Dynamic measurements based on screen constraints
    final horizontalMargin = (screenWidth * 0.04).clamp(10.0, 20.0);
    final navBarHeight = (screenHeight * 0.08).clamp(62.0, 70.0);
    final fabSize = (screenWidth * 0.15).clamp(52.0, 62.0);
    final fabGap = fabSize + 8.0;
    final fabTopOffset = -(fabSize * 0.42);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin,
        0,
        horizontalMargin,
        (bottomPadding > 0 ? bottomPadding : 12.0),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // ── Pill-shaped floating bar ──────────────────────────────────────
          Container(
            height: navBarHeight,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(navBarHeight / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.10),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left nav items
                Expanded(
                  child: Row(
                    children: [
                      _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Home'),
                      _buildNavItem(1, Icons.bar_chart_outlined, Icons.bar_chart, 'Analytics'),
                    ],
                  ),
                ),

                // Center gap — space for the raised FAB
                SizedBox(width: fabGap),

                // Right nav items
                Expanded(
                  child: Row(
                    children: [
                      _buildNavItem(2, Icons.menu_book_outlined, Icons.menu_book, 'Ledger'),
                      _buildNavItem(3, Icons.settings_outlined, Icons.settings, 'Settings'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Raised gradient FAB ───────────────────────────────────────────
          Positioned(
            top: fabTopOffset,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: fabSize,
                  height: fabSize,
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
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.50),
                        blurRadius: _glowAnimation.value * 1.5,
                        spreadRadius: _glowAnimation.value * 0.3,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _openAddTransactionModal,
                      child: Icon(
                        Icons.add,
                        size: (fabSize * 0.48).clamp(24.0, 30.0),
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
