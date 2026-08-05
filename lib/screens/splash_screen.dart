import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/security_provider.dart';
import '../providers/profile_provider.dart';
import '../services/profile_service.dart';
import '../services/database_service.dart';
import 'main_navigation_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _authFailed = false;

  @override
  void initState() {
    super.initState();
    _configureEdgeToEdge();
    _initializeApp();
  }

  void _configureEdgeToEdge() {
    // Enable edge-to-edge drawing under status and navigation bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // Ensures iOS clock/icons remain visible
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  Future<void> _initializeApp() async {
    setState(() => _authFailed = false);

    // 1. Initialise the profile meta-database and get the default profile.
    final defaultProfile = await ProfileService.init();

    // 2. Open the data Isar instance for that profile.
    await DatabaseService.switchToProfile(defaultProfile);

    // 3. Inform ProfileProvider of the active profile (it was created before
    //    ProfileService was ready, so we sync it now).
    if (mounted) {
      context.read<ProfileProvider>().setActiveProfileAfterInit(defaultProfile);
    }

    // 4. Pre-fetch transaction data.
    if (mounted) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      await provider.refreshData();
    }

    // 5. Small delay for smooth transition.
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // 6. Remove native splash so Flutter renders this splash screen image.
    FlutterNativeSplash.remove();

    // 7. Prompt for Biometrics — applies globally across all profiles.
    final security = Provider.of<SecurityProvider>(context, listen: false);
    final authenticated = await security.authenticate();

    if (authenticated && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
      );
    } else if (mounted) {
      setState(() => _authFailed = true);
    }
  }

  Future<void> _retryAuth() async {
    final security = Provider.of<SecurityProvider>(context, listen: false);
    final authenticated = await security.authenticate();

    if (authenticated && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
      );
    } else if (mounted) {
      setState(() => _authFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, // Draws image behind status bar
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              isDark ? 'assets/app_splashscreen_dark.png' : 'assets/app_splashscreen_light.png',
              fit: BoxFit.cover,
            ),
          ),
          if (_authFailed)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: ElevatedButton.icon(
                  onPressed: _retryAuth,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock Sivvai'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}