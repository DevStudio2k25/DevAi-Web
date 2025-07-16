import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'auth_screen.dart';
import 'prompt_form_screen.dart';

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

    // Check login status first
    if (!authService.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
      return;
    }

    // If logged in, check for API key
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            hasApiKey ? const HomeScreen() : const PromptFormScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  FadeTransition(
                    opacity: _fadeLogoAnimation,
                    child: ScaleTransition(
                      scale: _scaleLogoAnimation,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Lottie.asset(
                            'assets/lottie/DevAi.json',
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                              fontSize: 40,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Animated Tagline
                  FadeTransition(
                    opacity: _fadeTaglineAnimation,
                    child: Text(
                      'Your AI Development Companion',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
