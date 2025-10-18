import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorPaletteWidget extends StatefulWidget {
  final String content;
  final Function(Map<String, String>) onColorsChanged;

  const ColorPaletteWidget({
    super.key,
    required this.content,
    required this.onColorsChanged,
  });

  @override
  State<ColorPaletteWidget> createState() => _ColorPaletteWidgetState();
}

class _ColorPaletteWidgetState extends State<ColorPaletteWidget> {
  Map<String, String> _extractedColors = {};
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _extractColors();
  }

  void _extractColors() {
    final colorRegex = RegExp(r'#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})');

    final Map<String, String> colors = {};
    final lines = widget.content.split('\n');

    for (var line in lines) {
      final lowerLine = line.toLowerCase();
      final match = colorRegex.firstMatch(line);

      if (match != null) {
        final colorCode = match.group(0)!;

        // Try to identify color name from context
        if (lowerLine.contains('primary')) {
          colors['Primary'] = colorCode;
        } else if (lowerLine.contains('secondary')) {
          colors['Secondary'] = colorCode;
        } else if (lowerLine.contains('success')) {
          colors['Success'] = colorCode;
        } else if (lowerLine.contains('warning')) {
          colors['Warning'] = colorCode;
        } else if (lowerLine.contains('error') ||
            lowerLine.contains('danger')) {
          colors['Error'] = colorCode;
        } else if (lowerLine.contains('background')) {
          colors['Background'] = colorCode;
        } else if (lowerLine.contains('surface')) {
          colors['Surface'] = colorCode;
        } else if (lowerLine.contains('text')) {
          colors['Text'] = colorCode;
        }
      }
    }

    setState(() {
      _extractedColors = colors;
    });
  }

  Color _hexToColor(String hexCode) {
    try {
      final hex = hexCode.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  void _showColorPicker(String colorName, String currentHex) {
    showDialog(
      context: context,
      builder: (context) => _ColorPickerDialog(
        colorName: colorName,
        currentColor: _hexToColor(currentHex),
        onColorSelected: (newColor) {
          final newHex =
              '#${newColor.value.toRadixString(16).substring(2).toUpperCase()}';
          setState(() {
            _extractedColors[colorName] = newHex;
          });
          widget.onColorsChanged(_extractedColors);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_extractedColors.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.palette, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Color Palette',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                icon: Icon(_isEditing ? Icons.check : Icons.edit, size: 18),
                label: Text(_isEditing ? 'Done' : 'Customize'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _extractedColors.entries.map((entry) {
              return _buildColorChip(entry.key, entry.value, colorScheme);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(String name, String hexCode, ColorScheme colorScheme) {
    final color = _hexToColor(hexCode);

    return InkWell(
      onTap: _isEditing ? () => _showColorPicker(name, hexCode) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isEditing
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: _isEditing ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color preview
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: hexCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$hexCode copied!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Text(
                    hexCode,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            if (_isEditing) ...[
              const SizedBox(width: 4),
              Icon(Icons.edit, size: 14, color: colorScheme.primary),
            ],
          ],
        ),
      ),
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  final String colorName;
  final Color currentColor;
  final Function(Color) onColorSelected;

  const _ColorPickerDialog({
    required this.colorName,
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selectedColor;
  final TextEditingController _hexController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
    _hexController.text =
        '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _updateColorFromHex(String hex) {
    try {
      final cleanHex = hex.replaceAll('#', '');
      final color = Color(int.parse('FF$cleanHex', radix: 16));
      setState(() {
        _selectedColor = color;
      });
    } catch (e) {
      // Invalid hex
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text('Edit ${widget.colorName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color preview
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
              ),
            ),
            const SizedBox(height: 16),
            // Hex input
            TextField(
              controller: _hexController,
              decoration: InputDecoration(
                labelText: 'Hex Code',
                prefixText: '#',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _updateColorFromHex,
            ),
            const SizedBox(height: 16),
            // Preset colors
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getPresetColors().map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                      _hexController.text =
                          '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? colorScheme.primary
                            : Colors.black.withValues(alpha: 0.1),
                        width: _selectedColor == color ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onColorSelected(_selectedColor);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  List<Color> _getPresetColors() {
    return [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];
  }
}
