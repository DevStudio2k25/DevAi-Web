import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'windows11_theme.dart';

enum AppThemeStyle { classic, windows11 }

class ThemeManager {
  static ThemeData getTheme(AppThemeStyle style, bool isDark) {
    switch (style) {
      case AppThemeStyle.classic:
        return isDark ? AppConstants.darkTheme : AppConstants.lightTheme;
      case AppThemeStyle.windows11:
        return isDark
            ? Windows11Theme.darkTheme()
            : Windows11Theme.lightTheme();
    }
  }

  static String getThemeName(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.classic:
        return 'Classic';
      case AppThemeStyle.windows11:
        return 'Windows 11';
    }
  }

  static String getThemeDescription(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.classic:
        return 'Original DevAi theme with Material Design';
      case AppThemeStyle.windows11:
        return 'Modern Fluent Design with acrylic effects';
    }
  }

  static IconData getThemeIcon(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.classic:
        return Icons.palette_outlined;
      case AppThemeStyle.windows11:
        return Icons.window_rounded;
    }
  }
}
