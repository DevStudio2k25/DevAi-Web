import 'package:flutter/material.dart';

class ProjectFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController topicController;

  const ProjectFormFields({
    super.key,
    required this.nameController,
    required this.topicController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project Name Field
        TextFormField(
          controller: nameController,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            labelText: 'Project Name',
            labelStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
            hintText: 'e.g., TaskMaster, FitTrack',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: colorScheme.primary, width: 2.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: colorScheme.error, width: 2.5),
            ),
            filled: true,
            fillColor: colorScheme.surface,
            prefixIcon: Icon(
              Icons.rocket_launch_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a project name';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        // Project Description Field
        TextFormField(
          controller: topicController,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            labelText: 'Project Description',
            labelStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
            hintText: 'e.g., A task management app with reminders',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: colorScheme.primary, width: 2.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: colorScheme.error, width: 2.5),
            ),
            filled: true,
            fillColor: colorScheme.surface,
            alignLabelWithHint: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a project description';
            }
            return null;
          },
          maxLines: 4,
          minLines: 3,
        ),
      ],
    );
  }
}
