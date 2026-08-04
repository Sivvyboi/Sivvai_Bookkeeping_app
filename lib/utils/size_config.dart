import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// SizeConfig utility class for handling responsiveness across different screen sizes.
class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static late double textMultiplier;

  // ignore: strict_top_level_inference
  static init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    textMultiplier = (screenWidth < screenHeight ? screenWidth : screenHeight) / 100;
  }

  static double blockWidth(double percent) => blockSizeHorizontal * percent;
  static double blockHeight(double percent) => blockSizeVertical * percent;
  static double setSp(double fontSize) => (fontSize / 3.75) * textMultiplier;

  /// Formats currency to a compact version (M, B) based on digit length.
  /// Anything below 1M shows full figure with commas (e.g. ₦100,000.00).
  static String formatCompactCurrency(double amount) {
    final String sign = amount < 0 ? '-' : '';
    final double absAmount = amount.abs();

    if (absAmount >= 1000000000) {
      return '$sign₦${(absAmount / 1000000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}B';
    } else if (absAmount >= 1000000) {
      return '$sign₦${(absAmount / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    } else {
      // Use explicit pattern for thousand separators
      return '$sign₦${NumberFormat('#,##0.00', 'en_US').format(absAmount)}';
    }
  }
}

/// Syntactic sugar extensions for easier usage
extension SizeConfigExtension on num {
  double get w => SizeConfig.blockWidth(toDouble());
  double get h => SizeConfig.blockHeight(toDouble());
  double get sp => SizeConfig.setSp(toDouble());
  String get compactCurrency => SizeConfig.formatCompactCurrency(toDouble());
}
