import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'api_key_screen.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _boundEmail;

  @override
  void initState() {
    super.initState();
    _loadBoundEmail();
  }

  Future<void> _loadBoundEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final boundEmail = prefs.getString('bound_email');
    if (boundEmail != null && boundEmail.isNotEmpty) {
      setState(() {
        _boundEmail = boundEmail;
      });
    }
  }

  Future<void> _handleGoogleAuth() async {
    // Clear error message when starting a new sign-in attempt
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final credential = await authService.signInWithGoogle();

      if (credential != null) {
        // Check if the widget is still mounted
        if (!mounted) return;

        // Check if API key exists and navigate accordingly
        final hasApiKey = context.read<AppProvider>().hasApiKey;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                hasApiKey ? const MainScreen() : const ApiKeyScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Check if this is a device binding error
      if (e.toString().contains('device is already bound')) {
        // Load the bound email
        await _loadBoundEmail();

        if (!mounted) return;

        setState(() {
          if (_boundEmail != null) {
            _errorMessage =
                'This device is already linked to Google account: $_boundEmail\n\nPlease click "Continue with Google" again and select $_boundEmail to sign in.';
          } else {
            _errorMessage =
                'This device is already linked to another Google account. Please click "Continue with Google" again and select the correct account.';
          }
        });
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to authenticate: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
            colors: [
              colorScheme.primary.withValues(alpha: 0.8),
              colorScheme.secondary.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(70),
                    child: Lottie.asset(
                      'assets/lottie/DevAi.json',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // App Name
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Your AI Development Companion',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 48),

                  // Auth Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title
                              Text(
                                'Welcome to DevAi!',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _boundEmail != null
                                    ? 'Please sign in with: $_boundEmail'
                                    : 'Sign in with Google to start your journey',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),

                              // Error message
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: colorScheme.error,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Device Binding Error',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: colorScheme.onErrorContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Google Sign In Button
                              _isLoading
                                  ? Center(
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Signing in...',
                                            style: TextStyle(
                                              color: colorScheme.onSurface
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : FilledButton(
                                      onPressed: _handleGoogleAuth,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black87,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 18,
                                        ),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Google Logo from assets
                                          Image.asset(
                                            'assets/images/Google.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Continue with Google',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
