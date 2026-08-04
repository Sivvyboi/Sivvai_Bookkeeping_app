import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/security_provider.dart';
import 'main_navigation_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Kick off any data refreshing while the logo is visible
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    await provider.refreshData();

    // 2. SET DURATION HERE: Forces the screen to display for at least 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. TARGET SCREEN HERE: Send them to HomeScreen and remove Splash from the stack
    if (mounted) {
      final security = Provider.of<SecurityProvider>(context, listen: false);
      final authenticated = await security.authenticate();
      
      if (authenticated && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
        );
      } else {
        // If authentication failed or cancelled, we stay on splash or show an error
        // For simplicity, we just try again if they tap or similar, 
        // but usually, we'd have a "Retry" button.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF01040B) : Colors.white,
      body: Center(
        child: Image.asset(
          isDark ? 'assets/logo/app_icon_dark.png' : 'assets/logo/app_icon_light.png',
          width: MediaQuery.of(context).size.width * 0.6,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}