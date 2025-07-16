import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  static const String appName = 'DevAi';
  static const String appVersion = '1.0.1';

  // Platform options
  static const List<String> platforms = ['App', 'Web'];

  static const Map<String, List<String>> techStacks = {
    'App': ['Flutter', 'Kotlin', 'Java', 'Swift', 'React Native'],
    'Web': [
      'HTML + CSS + JavaScript',
      'React.js',
      'Next.js',
      'Vue.js',
      'Angular',
      'Svelte',
    ],
  };

  // Theme Data
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
    fontFamily: GoogleFonts.roboto().fontFamily,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
    fontFamily: GoogleFonts.roboto().fontFamily,
  );

  // Text Styles
  static TextStyle get monoTextStyle => GoogleFonts.jetBrainsMono();

  // Animations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Curve defaultAnimationCurve = Curves.easeInOut;
}
