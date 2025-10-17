import 'package:flutter/material.dart';

class CachedCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? child;
  final Color? backgroundColor;

  const CachedCircleAvatar({
    super.key,
    this.imageUrl,
    required this.radius,
    this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: imageUrl != null
          ? ResizeImage(
              NetworkImage(
                imageUrl!,
                headers: const {
                  'Cache-Control': 'max-age=86400', // Cache for 24 hours
                },
              ),
              width: (radius * 2 * MediaQuery.of(context).devicePixelRatio)
                  .toInt(),
              height: (radius * 2 * MediaQuery.of(context).devicePixelRatio)
                  .toInt(),
            )
          : null,
      onBackgroundImageError: imageUrl != null
          ? (exception, stackTrace) {
              debugPrint('Error loading profile image: $exception');
            }
          : null,
      child: imageUrl == null ? child : null,
    );
  }
}
