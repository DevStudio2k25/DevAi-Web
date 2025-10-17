import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class PlatformChipSelector extends StatelessWidget {
  final String selectedPlatform;
  final ValueChanged<String> onPlatformSelected;

  const PlatformChipSelector({
    super.key,
    required this.selectedPlatform,
    required this.onPlatformSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.devices_rounded, color: colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Platform',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppConstants.platforms.map((platform) {
            final isSelected = platform == selectedPlatform;
            return FilterChip(
              selected: isSelected,
              label: Text(platform),
              onSelected: (_) => onPlatformSelected(platform),
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
