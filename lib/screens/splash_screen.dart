// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'auth_screen.dart';
import 'api_key_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeLogoAnimation;
  late Animation<double> _scaleLogoAnimation;
  late Animation<double> _fadeTextAnimation;
  late Animation<double> _slideTextAnimation;
  late Animation<double> _fadeTaglineAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000), // 8 seconds total
    );

    // Logo fade in and scale (0-2s)
    _fadeLogoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    _scaleLogoAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.elasticOut),
      ),
    );

    // App name text fade and slide (2-4s)
    _fadeTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideTextAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5, curve: Curves.easeOut),
      ),
    );

    // Tagline fade in (4-6s)
    _fadeTaglineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75, curve: Curves.easeIn),
      ),
    );

    // Pulse animation for the logo (6-8s)
    _pulseAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.1),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.1, end: 1.0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.75, 1.0, curve: Curves.easeInOut),
          ),
        );

    // Start animation and navigate after completion
    _controller.forward().then((_) {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    final authService = context.read<AuthService>();
    final hasApiKey = context.read<AppProvider>().hasApiKey;

    print('🔍 [SPLASH] Checking navigation...');
    print('👤 [SPLASH] Is logged in: ${authService.isLoggedIn}');
    print('🔑 [SPLASH] Has API key: $hasApiKey');

    // Check login status first
    if (!authService.isLoggedIn) {
      print('🧭 [SPLASH] → Auth Screen (not logged in)');
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => AuthScreen()));
      return;
    }

    // If logged in, check for API key
    if (!hasApiKey) {
      print('🧭 [SPLASH] → API Key Screen (no API key)');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ApiKeyScreen()),
      );
      return;
    }

    // All good, go to home
    print('🧭 [SPLASH] → Main Screen (all good)');
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primary, colorScheme.secondary],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  top: -100 + (_pulseAnimation.value * 20),
                  right: -100,
                  child: Opacity(
                    opacity: 0.1,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  bottom: -150 + (_pulseAnimation.value * -20),
                  left: -100,
                  child: Opacity(
                    opacity: 0.1,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo with glow
                      FadeTransition(
                        opacity: _fadeLogoAnimation,
                        child: ScaleTransition(
                          scale: _scaleLogoAnimation,
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  child: Lottie.asset(
                                    'assets/lottie/DevAi.json',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Animated App Name
                      FadeTransition(
                        opacity: _fadeTextAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideTextAnimation.value),
                          child: Text(
                            AppConstants.appName,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      offset: const Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Animated Tagline
                      FadeTransition(
                        opacity: _fadeTaglineAnimation,
                        child: Text(
                          'Your AI Development Companion',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Loading indicator
                      FadeTransition(
                        opacity: _fadeTaglineAnimation,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
