// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/size_config.dart';

/// A widget that displays currency figures dynamically.
/// It uses compact formatting by default and shows the full figure in a transparent overlay on tap.
class ResponsiveValueText extends StatelessWidget {
  final double amount;
  final TextStyle style;
  final String label;
  final bool compactByDefault;

  const ResponsiveValueText({
    super.key,
    required this.amount,
    required this.style,
    required this.label,
    this.compactByDefault = true,
  });

  void _showFullValueOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final format = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.05), // Lightweight transparent background
      barrierDismissible: true,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevents dismissal when tapping inside the container
              child: Container(
                padding: EdgeInsets.all(SizeConfig.blockWidth(6)),
                margin: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth(8)),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color?.withOpacity(0.98) ?? theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(SizeConfig.blockWidth(5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Full Value: $label',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: SizeConfig.setSp(14),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockHeight(1.5)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        format.format(amount),
                        style: TextStyle(
                          color: theme.textTheme.displayLarge?.color,
                          fontSize: SizeConfig.setSp(28),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockHeight(2)),
                    Text(
                      'Tap anywhere outside to dismiss',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                        fontSize: SizeConfig.setSp(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
    final displayText = compactByDefault 
        ? amount.compactCurrency 
        : format.format(amount);

    return GestureDetector(
      onTap: () => _showFullValueOverlay(context),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          displayText,
          style: style,
          maxLines: 1,
        ),
      ),
    );
  }
}
