import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class ApiKeyScreen extends StatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  bool _obscureText = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _loadExistingApiKey();
  }

  Future<void> _loadExistingApiKey() async {
    final authService = context.read<AuthService>();
    final apiKey = await authService.getUserApiKey();
    if (apiKey != null && mounted) {
      _apiKeyController.text = apiKey;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _launchApiKeyUrl() async {
    final Uri url = Uri.parse('https://aistudio.google.com/apikey');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the API key page')),
        );
      }
    }
  }

  Future<void> _submitApiKey() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isVerifying = true;
      });

      try {
        final apiKey = _apiKeyController.text.trim();
        final authService = context.read<AuthService>();

        // Check if user is logged in
        if (!authService.isLoggedIn) {
          throw Exception('Please sign in first');
        }

        // Get the GeminiService from the provider
        final geminiService = Provider.of<AppProvider>(
          context,
          listen: false,
        ).geminiService;

        // Verify the API key
        final isValid = await geminiService.verifyApiKey(apiKey);

        if (!isValid) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Invalid API key. Please check and try again.',
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          setState(() {
            _isVerifying = false;
          });
          return;
        }

        // Save the API key if it's valid
        if (!mounted) return;
        await context.read<AppProvider>().setApiKey(apiKey);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('API key saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to main screen after successful API key setup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });
        }
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
                  // App Logo
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
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your AI Development Companion',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 48),
                  // Glassmorphic Card
                  Container(
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
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Icon
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.vpn_key_rounded,
                                    size: 40,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Setup API Key',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enter your Gemini API key to unlock AI-powered features',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                TextFormField(
                                  controller: _apiKeyController,
                                  decoration: InputDecoration(
                                    labelText: 'Gemini API Key',
                                    hintText: 'AIzaSy...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: colorScheme.outline.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surface.withValues(
                                      alpha: 0.5,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.key_rounded,
                                      color: colorScheme.primary,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: _obscureText,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your API key';
                                    }
                                    if (!value.startsWith('AIza')) {
                                      return 'Invalid API key format';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _submitApiKey(),
                                ),
                                const SizedBox(height: 24),
                                FilledButton.icon(
                                  onPressed: _isVerifying
                                      ? null
                                      : _submitApiKey,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: _isVerifying
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colorScheme.onPrimary,
                                          ),
                                        )
                                      : const Icon(Icons.check_circle_rounded),
                                  label: Text(
                                    _isVerifying
                                        ? 'Verifying...'
                                        : 'Verify & Continue',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: _launchApiKeyUrl,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: BorderSide(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(Icons.open_in_new_rounded),
                                  label: const Text(
                                    'Get Free API Key',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
