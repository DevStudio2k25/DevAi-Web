import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class InlineColorPaletteWidget extends StatefulWidget {
  final Map<String, String> colors;
  final Function(Map<String, String>) onColorsChanged;

  const InlineColorPaletteWidget({
    super.key,
    required this.colors,
    required this.onColorsChanged,
  });

  @override
  State<InlineColorPaletteWidget> createState() =>
      _InlineColorPaletteWidgetState();
}

class _InlineColorPaletteWidgetState extends State<InlineColorPaletteWidget> {
  late Map<String, String> _currentColors;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _currentColors = Map.from(widget.colors);
  }

  Color _hexToColor(String hexCode) {
    try {
      final hex = hexCode.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  Future<void> _showColorPicker(String colorName, String currentHex) async {
    Color selectedColor = _hexToColor(currentHex);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $colorName'),
        content: SingleChildScrollView(
          child: ColorPicker(
            color: selectedColor,
            onColorChanged: (Color color) {
              selectedColor = color;
            },
            width: 40,
            height: 40,
            borderRadius: 20,
            spacing: 5,
            runSpacing: 5,
            wheelDiameter: 200,
            heading: Text(
              'Select color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subheading: Text(
              'Select color shade',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            wheelSubheading: Text(
              'Selected color and its shades',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            showMaterialName: true,
            showColorName: true,
            showColorCode: true,
            copyPasteBehavior: const ColorPickerCopyPasteBehavior(
              longPressMenu: true,
            ),
            materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
            colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
            colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.both: false,
              ColorPickerType.primary: true,
              ColorPickerType.accent: true,
              ColorPickerType.bw: false,
              ColorPickerType.custom: false,
              ColorPickerType.wheel: true,
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newHex = _colorToHex(selectedColor);
              setState(() {
                _currentColors[colorName] = newHex;
              });
              widget.onColorsChanged(_currentColors);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentColors.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.3),
            colorScheme.secondaryContainer.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.palette_rounded,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Interactive Color Palette',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          // Color Grid
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tap any color to customize',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _currentColors.entries.map((entry) {
                      return _buildColorCard(
                        entry.key,
                        entry.value,
                        colorScheme,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorCard(String name, String hexCode, ColorScheme colorScheme) {
    final color = _hexToColor(hexCode);
    final isLight = color.computeLuminance() > 0.5;

    return InkWell(
      onTap: () => _showColorPicker(name, hexCode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color preview with gradient
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.edit_rounded,
                  color: isLight ? Colors.black54 : Colors.white70,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Color name
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Hex code with copy
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: hexCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$hexCode copied!'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        hexCode,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.copy_rounded,
                      size: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
