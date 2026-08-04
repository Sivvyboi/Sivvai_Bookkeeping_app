import 'package:flutter/material.dart';
import '../utils/size_config.dart';

class AdaptiveBrandLogo extends StatelessWidget {
  final double? width;
  final double? height;

  const AdaptiveBrandLogo({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Read the current active brightness state from the context
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Image.asset(
      isDark ? 'assets/logo/app_icon_dark.png' : 'assets/logo/app_icon_light.png',
      width: width ?? 40.w, // Scales via your responsive configuration size bounds
      height: height ?? 40.w,
      fit: BoxFit.contain,
    );
  }
}