import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'home_screen.dart';

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

    // 2. SET DURATION HERE: Forces the screen to display for at least 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // 3. TARGET SCREEN HERE: Send them to HomeScreen and remove Splash from the stack
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
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