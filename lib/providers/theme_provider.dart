// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../utils/size_config.dart';

/// Custom theme extension for bookkeeping-specific semantic colors, gradients, and variations.
class StatusColors extends ThemeExtension<StatusColors> {
  final Color? inflow;
  final Color? inflowContainer;
  final Color? onInflowContainer;
  final Color? onDashboardInflow;
  final Gradient? inflowGradient;
  
  final Color? outflow;
  final Color? outflowContainer;
  final Color? onOutflowContainer;
  final Color? onDashboardOutflow;
  final Gradient? outflowGradient;
  
  final Color? debt;
  final Color? debtContainer;
  final Color? onDebtContainer;
  final Color? onDashboardDebt;
  
  final Gradient? dashboardGradient;

  const StatusColors({
    required this.inflow,
    required this.inflowContainer,
    required this.onInflowContainer,
    required this.onDashboardInflow,
    this.inflowGradient,
    required this.outflow,
    required this.outflowContainer,
    required this.onOutflowContainer,
    required this.onDashboardOutflow,
    this.outflowGradient,
    required this.debt,
    required this.debtContainer,
    required this.onDebtContainer,
    required this.onDashboardDebt,
    this.dashboardGradient,
  });

  @override
  StatusColors copyWith({
    Color? inflow,
    Color? inflowContainer,
    Color? onInflowContainer,
    Color? onDashboardInflow,
    Gradient? inflowGradient,
    Color? outflow,
    Color? outflowContainer,
    Color? onOutflowContainer,
    Color? onDashboardOutflow,
    Gradient? outflowGradient,
    Color? debt,
    Color? debtContainer,
    Color? onDebtContainer,
    Color? onDashboardDebt,
    Gradient? dashboardGradient,
  }) {
    return StatusColors(
      inflow: inflow ?? this.inflow,
      inflowContainer: inflowContainer ?? this.inflowContainer,
      onInflowContainer: onInflowContainer ?? this.onInflowContainer,
      onDashboardInflow: onDashboardInflow ?? this.onDashboardInflow,
      inflowGradient: inflowGradient ?? this.inflowGradient,
      outflow: outflow ?? this.outflow,
      outflowContainer: outflowContainer ?? this.outflowContainer,
      onOutflowContainer: onOutflowContainer ?? this.onOutflowContainer,
      onDashboardOutflow: onDashboardOutflow ?? this.onDashboardOutflow,
      outflowGradient: outflowGradient ?? this.outflowGradient,
      debt: debt ?? this.debt,
      debtContainer: debtContainer ?? this.debtContainer,
      onDebtContainer: onDebtContainer ?? this.onDebtContainer,
      onDashboardDebt: onDashboardDebt ?? this.onDashboardDebt,
      dashboardGradient: dashboardGradient ?? this.dashboardGradient,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      inflow: Color.lerp(inflow, other.inflow, t),
      inflowContainer: Color.lerp(inflowContainer, other.inflowContainer, t),
      onInflowContainer: Color.lerp(onInflowContainer, other.onInflowContainer, t),
      onDashboardInflow: Color.lerp(onDashboardInflow, other.onDashboardInflow, t),
      inflowGradient: Gradient.lerp(inflowGradient, other.inflowGradient, t),
      outflow: Color.lerp(outflow, other.outflow, t),
      outflowContainer: Color.lerp(outflowContainer, other.outflowContainer, t),
      onOutflowContainer: Color.lerp(onOutflowContainer, other.onOutflowContainer, t),
      onDashboardOutflow: Color.lerp(onDashboardOutflow, other.onDashboardOutflow, t),
      outflowGradient: Gradient.lerp(outflowGradient, other.outflowGradient, t),
      debt: Color.lerp(debt, other.debt, t),
      debtContainer: Color.lerp(debtContainer, other.debtContainer, t),
      onDebtContainer: Color.lerp(onDebtContainer, other.onDebtContainer, t),
      onDashboardDebt: Color.lerp(onDashboardDebt, other.onDashboardDebt, t),
      dashboardGradient: Gradient.lerp(dashboardGradient, other.dashboardGradient, t),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get currentThemeMode => _themeMode;

  /// Professional Light Theme
  /// Crisp pure white canvas with brand green/cyan/blue accents.
  ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF10B981),
      primary: const Color(0xFF10B981),
      secondary: const Color(0xFF06B6D4),
      surface: Colors.white,
      background: const Color(0xFFFFFFFF),
      error: const Color(0xFFD32F2F),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1E293B),
    );

    return _buildBaseTheme(colorScheme, Brightness.light).copyWith(
      extensions: [
        StatusColors(
          inflow: const Color(0xFF2E7D32),
          inflowContainer: const Color(0xFFE8F5E9),
          onInflowContainer: const Color(0xFF1B5E20),
          onDashboardInflow: Colors.white,
          inflowGradient: LinearGradient(
            colors: [const Color(0xFF2E7D32), Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          outflow: const Color(0xFFD32F2F),
          outflowContainer: const Color(0xFFFFEBEE),
          onOutflowContainer: const Color(0xFFB71C1C),
          onDashboardOutflow: Colors.white,
          outflowGradient: LinearGradient(
            colors: [const Color(0xFFD32F2F), Colors.red.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          debt: const Color(0xFFF57C00),
          debtContainer: const Color(0xFFFFF3E0),
          onDebtContainer: const Color(0xFFE65100),
          onDashboardDebt: Colors.white,
          dashboardGradient: const LinearGradient(
            colors: [
              Color(0xFF10B981), // Emerald green
              Color(0xFF06B6D4), // Bright cyan
              Color(0xFF1D4ED8), // Deep blue
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      ],
    );
  }

  /// Midnight Dark Theme
  /// Deep midnight blue/grey (#0F172A) background with vibrant accents.
  ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF06B6D4),
      brightness: Brightness.dark,
      primary: const Color(0xFF06B6D4),
      secondary: const Color(0xFF10B981),
      surface: const Color(0xFF1E293B), // Midnight Blue/Grey Surface
      background: const Color(0xFF0F172A), // Deep Midnight Background #0F172A
      error: const Color(0xFFF87171),
      onPrimary: const Color(0xFF0F172A),
      onSecondary: const Color(0xFF0F172A),
      onSurface: const Color(0xFFF1F5F9),
    );

    return _buildBaseTheme(colorScheme, Brightness.dark).copyWith(
      extensions: [
        StatusColors(
          inflow: const Color(0xFF4ADE80),
          inflowContainer: const Color(0xFF4ADE80).withValues(alpha: .15),
          onInflowContainer: const Color(0xFF4ADE80),
          onDashboardInflow: Colors.white,
          inflowGradient: LinearGradient(
            colors: [const Color(0xFF4ADE80), Colors.green.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          outflow: const Color(0xFFFB7185),
          outflowContainer: const Color(0xFFFB7185).withValues(alpha: .15),
          onOutflowContainer: const Color(0xFFFB7185),
          onDashboardOutflow: Colors.white,
          outflowGradient: const LinearGradient(
            colors: [Color(0xFFFB7185), Color(0xFFF43F5E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          debt: const Color(0xFFFB923C),
          debtContainer: const Color(0xFFFB923C).withValues(alpha: .15),
          onDebtContainer: const Color(0xFFFB923C),
          onDashboardDebt: Colors.white,
          dashboardGradient: const LinearGradient(
            colors: [
              Color(0xFF10B981), // Emerald green
              Color(0xFF06B6D4), // Bright cyan
              Color(0xFF1D4ED8), // Deep blue
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      ],
    );
  }

  ThemeData _buildBaseTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseTextTheme = brightness == Brightness.light ? Typography.blackMountainView : Typography.whiteMountainView;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      scaffoldBackgroundColor: colorScheme.background,
      
      textTheme: baseTextTheme.copyWith(
        displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, letterSpacing: -1.0, color: colorScheme.onSurface),
        titleLarge: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        bodyLarge: TextStyle(fontSize: 16.sp, color: colorScheme.onSurface),
        bodyMedium: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white70 : Colors.black54),
        labelSmall: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: colorScheme.onSurface.withValues(alpha: .6)),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? colorScheme.surface : colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black12,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: isDark ? BorderSide(color: Colors.white.withValues(alpha: .08)) : BorderSide.none,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: isDark ? colorScheme.onPrimary : Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          elevation: 2,
          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? colorScheme.primary : colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
      ),
      
      tabBarTheme: TabBarThemeData(
        indicatorColor: isDark ? colorScheme.secondary : Colors.white,
        labelColor: isDark ? colorScheme.secondary : Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white.withValues(alpha: .08) : Colors.grey.shade200,
        thickness: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark ? colorScheme.surface : Colors.grey.shade100,
        selectedColor: colorScheme.primary,
        secondarySelectedColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        labelStyle: TextStyle(color: colorScheme.onSurface, fontSize: 12.sp),
        secondaryLabelStyle: TextStyle(color: colorScheme.onPrimary, fontSize: 12.sp),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        side: isDark ? BorderSide(color: Colors.white.withValues(alpha: .08)) : BorderSide.none,
      ),
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _themeService.saveThemeMode(mode);
  }

  Future<void> _loadTheme() async {
    _themeMode = await _themeService.loadThemeMode();
    notifyListeners();
  }
}
