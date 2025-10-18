import 'package:flutter/material.dart';

/// Windows 11 Fluent Design Theme
/// Implements modern Windows 11 design principles with acrylic effects,
/// rounded corners, and smooth animations
class Windows11Theme {
  // Windows 11 Color Palette
  static const Color accentBlue = Color(0xFF0078D4);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentTeal = Color(0xFF00B7C3);

  // Neutral colors
  static const Color cardBackground = Color(0xFFF3F3F3);
  static const Color cardBackgroundDark = Color(0xFF202020);

  // Border radius (Windows 11 standard)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  // Elevation and shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadowHover => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);

  /// Light Theme
  static ThemeData lightTheme() {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: accentBlue,
      secondary: accentPurple,
      tertiary: accentTeal,
      surface: Colors.white,
      surfaceContainerHighest: Color(0xFFF3F3F3),
      onSurface: Color(0xFF1C1C1C),
      onSurfaceVariant: Color(0xFF5C5C5C),
      outline: Color(0xFFE0E0E0),
      primaryContainer: Color(0xFFE3F2FD),
      secondaryContainer: Color(0xFFF3E5F5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),

      // Card theme with Windows 11 style
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        color: Colors.white,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1C1C1C),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1C1C),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: accentBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // Button themes
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F3F3),
        selectedColor: accentBlue,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXLarge),
          ),
        ),
      ),
    );
  }

  /// Dark Theme
  static ThemeData darkTheme() {
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: Color(0xFF60A5FA),
      secondary: Color(0xFFA78BFA),
      tertiary: Color(0xFF22D3EE),
      surface: Color(0xFF1C1C1C),
      surfaceContainerHighest: Color(0xFF2C2C2C),
      onSurface: Color(0xFFE5E5E5),
      onSurfaceVariant: Color(0xFFA0A0A0),
      outline: Color(0xFF3C3C3C),
      primaryContainer: Color(0xFF1E3A5F),
      secondaryContainer: Color(0xFF3B2F5F),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        color: const Color(0xFF1C1C1C),
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFE5E5E5),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE5E5E5),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Color(0xFF3C3C3C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Color(0xFF3C3C3C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Color(0xFF60A5FA), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2C2C2C),
        selectedColor: const Color(0xFF60A5FA),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),

      dialogTheme: DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXLarge),
          ),
        ),
      ),
    );
  }
}

/// Windows 11 Acrylic Card Widget
class AcrylicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  const AcrylicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? Windows11Theme.radiusLarge;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: Windows11Theme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Animated Acrylic Card with hover effect
class AnimatedAcrylicCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;

  const AnimatedAcrylicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
  });

  @override
  State<AnimatedAcrylicCard> createState() => _AnimatedAcrylicCardState();
}

class _AnimatedAcrylicCardState extends State<AnimatedAcrylicCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = widget.borderRadius ?? Windows11Theme.radiusLarge;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Windows11Theme.animationNormal,
        curve: Curves.easeOutCubic,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: _isHovered
                ? colorScheme.primary.withOpacity(0.3)
                : colorScheme.outline.withOpacity(0.2),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? Windows11Theme.cardShadowHover
              : Windows11Theme.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
