import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
    // 1. Fetch background data
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    await provider.refreshData();

    // 2. Optional: Add a brief minimum display duration so the screen isn't a flash
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 3. Prompt for authentication while still on the splash screen
    final security = Provider.of<SecurityProvider>(context, listen: false);
    final authenticated = await security.authenticate();

    if (authenticated && mounted) {
      // 4. Remove native splash overlay right before transitioning away
      FlutterNativeSplash.remove();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
      );
    } else {
      // If auth fails/cancels, remove the native splash so the user can see your fallback UI
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          isDark ? 'assets/app_splashscreen_dark.png' : 'assets/app_splashscreen_light.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}