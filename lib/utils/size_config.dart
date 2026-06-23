import 'package:flutter/widgets.dart';

/// SizeConfig utility class for handling responsiveness across different screen sizes.
/// Initialize this in the main build method of your app or at the start of every screen.
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

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    // We use the shorter side for text scaling to keep it consistent on tablets/landscape
    textMultiplier = (screenWidth < screenHeight ? screenWidth : screenHeight) / 100;
  }

  /// Returns a width value scaled to a percentage of the screen width.
  static double blockWidth(double percent) => blockSizeHorizontal * percent;

  /// Returns a height value scaled to a percentage of the screen height.
  static double blockHeight(double percent) => blockSizeVertical * percent;

  /// Returns a font size scaled based on the screen's shortest side to maintain readability.
  static double setSp(double fontSize) {
    // 3.75 is a baseline based on a standard phone width (e.g. 375px)
    return (fontSize / 3.75) * textMultiplier;
  }
}

/// Syntactic sugar extensions for easier usage
extension SizeConfigExtension on num {
  double get w => SizeConfig.blockWidth(toDouble());
  double get h => SizeConfig.blockHeight(toDouble());
  double get sp => SizeConfig.setSp(toDouble());
}
