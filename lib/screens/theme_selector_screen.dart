import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/home_preview_widget.dart';

class ThemeSelectorScreen extends StatefulWidget {
  const ThemeSelectorScreen({super.key});

  @override
  State<ThemeSelectorScreen> createState() => _ThemeSelectorScreenState();
}

class _ThemeSelectorScreenState extends State<ThemeSelectorScreen> {
  bool _previewDarkMode = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _previewDarkMode = provider.themeMode == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme Settings',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose your preferred theme style',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Dark mode toggle at top
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_rounded, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Preview in Dark Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Switch(
                      value: _previewDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _previewDarkMode = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Single column theme cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  children: [
                    _buildThemeCard(AppThemeStyle.windows11, provider),
                    const SizedBox(height: 16),
                    _buildThemeCard(AppThemeStyle.classic, provider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(AppThemeStyle style, AppProvider provider) {
    final isActive =
        (style == AppThemeStyle.classic && provider.themeStyle == 'classic') ||
        (style == AppThemeStyle.windows11 &&
            provider.themeStyle == 'windows11');
    final colorScheme = Theme.of(context).colorScheme;
    final previewTheme = ThemeManager.getTheme(style, _previewDarkMode);

    // Get screen height for dynamic card sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.6; // 60% of screen height

    return SizedBox(
      height: cardHeight,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.2),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      ThemeManager.getThemeIcon(style),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ThemeManager.getThemeName(style),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          ThemeManager.getThemeDescription(style),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Preview with flexible height
            Flexible(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: previewTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: previewTheme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Theme(
                  data: previewTheme,
                  child: _buildMiniPreview(previewTheme.colorScheme),
                ),
              ),
            ),

            // Compact Apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final styleString = style == AppThemeStyle.classic
                        ? 'classic'
                        : 'windows11';
                    await provider.setThemeStyle(styleString);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${ThemeManager.getThemeName(style)} applied!',
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    isActive ? Icons.check_circle : Icons.brush_rounded,
                    size: 18,
                  ),
                  label: Text(isActive ? 'Active' : 'Apply Theme'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isActive
                        ? Colors.green
                        : colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPreview(ColorScheme colorScheme) {
    // Use LayoutBuilder to get available space
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          // Print size and ratio to console
          print(
            '📐 Preview Size: ${width.toStringAsFixed(1)} x ${height.toStringAsFixed(1)}',
          );
          print('📊 Ratio: ${(width / height).toStringAsFixed(2)}');

          return SizedBox(
            width: width,
            height: height,
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width * 2,
                height: height * 2,
                child: HomePreviewWidget(scale: 1.0, isInteractive: false),
              ),
            ),
          );
        },
      ),
    );
  }
}
