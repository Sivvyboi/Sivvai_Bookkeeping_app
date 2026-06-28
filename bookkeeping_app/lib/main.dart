import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'providers/transaction_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/size_config.dart'; // Make sure this path matches your file structure

void main() async {
  // 1. Ensure Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Lock orientation to portrait only (Secondary programmatic safety net)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. Initialize the Isar database singleton
  await DatabaseService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. Initialize SizeConfig immediately using the correct top-level context
        SizeConfig.init(context);

        // 2. Consume ThemeProvider safely now that font multipliers are initialized
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            final isDark = themeProvider.currentThemeMode == ThemeMode.dark ||
                (themeProvider.currentThemeMode == ThemeMode.system &&
                    MediaQuery.of(context).platformBrightness == Brightness.dark);

            // Set System UI Overlay Style based on the current theme dynamically
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light, // Kept light as per your design
              systemNavigationBarColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            ));

            return MaterialApp(
              title: 'Sivvai Bookkeeper',
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.currentThemeMode,
              theme: themeProvider.lightTheme,
              darkTheme: themeProvider.darkTheme,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
