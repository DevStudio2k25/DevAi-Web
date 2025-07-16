import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Codec;
import 'package:flutter/services.dart';

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
      child: imageUrl == null ? child : null,
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('Error loading profile image: $exception');
        // The CircleAvatar will automatically show the child (fallback) widget if the image fails to load
      },
    );
  }
}
