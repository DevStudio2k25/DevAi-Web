import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_constants.dart';
import 'providers/app_provider.dart';
import 'screens/api_key_screen.dart';
import 'screens/prompt_form_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/chat_result_screen.dart';
import 'screens/public_history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'services/gemini_service.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService();
  final geminiService = GeminiService(storageService);
  final authService = AuthService(prefs);

  await geminiService.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
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

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppConstants.lightTheme,
      darkTheme: AppConstants.darkTheme,
      themeMode: provider.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/api-key', // Start with API key screen for Windows
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthScreen(),
        '/api-key': (context) => const ApiKeyScreen(),
        '/home': (context) => const HomeScreen(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/public-history': (context) => const PublicHistoryScreen(),
      },
    );
  }
}
