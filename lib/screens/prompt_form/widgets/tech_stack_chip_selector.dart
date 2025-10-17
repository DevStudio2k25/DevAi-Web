import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class TechStackChipSelector extends StatelessWidget {
  final String selectedPlatform;
  final String selectedTechStack;
  final ValueChanged<String> onTechStackSelected;

  const TechStackChipSelector({
    super.key,
    required this.selectedPlatform,
    required this.selectedTechStack,
    required this.onTechStackSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final techStacks = AppConstants.techStacks[selectedPlatform] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.code_rounded, color: colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Tech Stack',
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
          children: techStacks.map((techStack) {
            final isSelected = techStack == selectedTechStack;
            return FilterChip(
              selected: isSelected,
              label: Text(techStack),
              onSelected: (_) => onTechStackSelected(techStack),
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.secondaryContainer,
              checkmarkColor: colorScheme.onSecondaryContainer,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurface,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.secondary
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
