import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';
import '../services/gemini_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

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
            MaterialPageRoute(builder: (context) => const HomeScreen()),
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
              colorScheme.primary.withOpacity(0.8),
              colorScheme.secondary.withOpacity(0.9),
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
                      color: colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Enter your API Key',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: colorScheme.onSurface),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _apiKeyController,
                                  decoration: InputDecoration(
                                    labelText: 'API Key',
                                    hintText: 'Enter your API key',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surface,
                                    prefixIcon: const Icon(Icons.key),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off
                                            : Icons.visibility,
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
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _submitApiKey(),
                                ),
                                const SizedBox(height: 24),
                                FilledButton(
                                  onPressed: _isVerifying
                                      ? null
                                      : _submitApiKey,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isVerifying
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: colorScheme.onPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text('Verifying...'),
                                          ],
                                        )
                                      : const Text('Continue'),
                                ),
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: _launchApiKeyUrl,
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Get an API Key'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: colorScheme.primary,
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
