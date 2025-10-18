import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import Firebase options
import 'constants/app_constants.dart';
import 'theme/theme_manager.dart';
import 'providers/app_provider.dart';
import 'screens/api_key_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/history_screen.dart';
import 'screens/public_history_screen.dart';
import 'screens/main_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/promo_code_screen.dart';
import 'screens/theme_selector_screen.dart';
import 'services/gemini_service.dart';
import 'services/gemini_streaming_service.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Hide both status bar and navigation bar
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService();
  final geminiService = GeminiService(storageService);
  final geminiStreamingService = GeminiStreamingService(storageService);
  final authService = AuthService(prefs);

  await geminiService.initialize();
  await geminiStreamingService.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<GeminiStreamingService>.value(value: geminiStreamingService),
        ChangeNotifierProvider(
          create: (_) =>
              AppProvider(storageService, geminiService, prefs, authService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    // Get theme style
    final themeStyle = provider.themeStyle == 'classic'
        ? AppThemeStyle.classic
        : AppThemeStyle.windows11;

    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeManager.getTheme(themeStyle, false),
      darkTheme: ThemeManager.getTheme(themeStyle, true),
      themeMode: provider.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeOutCubic,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthScreen(),
        '/api-key': (context) => const ApiKeyScreen(),
        '/home': (context) => const MainScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/public-history': (context) => const PublicHistoryScreen(),
        '/promo-code': (context) => const PromoCodeScreen(),
        '/theme-selector': (context) => const ThemeSelectorScreen(),
      },
    );
  }
}
