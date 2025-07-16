import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLogoWidget extends StatelessWidget {
  final double size;
  final double borderRadius;

  const AppLogoWidget({super.key, this.size = 120, this.borderRadius = 100});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Lottie.asset(
        'assets/lottie/DevAi.json',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
