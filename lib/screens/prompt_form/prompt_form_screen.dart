// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../../constants/app_constants.dart';
import '../../models/prompt_request.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';
import '../../services/gemini_streaming_service.dart';
import '../chat_result_streaming_screen.dart';
import '../../widgets/no_tokens_dialog.dart';
import 'widgets/platform_chip_selector.dart';
import 'widgets/tech_stack_chip_selector.dart';
import 'widgets/project_form_fields.dart';

class PromptFormScreen extends StatefulWidget {
  final String? initialProjectName;
  final String? initialProjectDescription;
  final String? initialPlatform;
  final String? initialTechStack;

  const PromptFormScreen({
    super.key,
    this.initialProjectName,
    this.initialProjectDescription,
    this.initialPlatform,
    this.initialTechStack,
  });

  @override
  State<PromptFormScreen> createState() => _PromptFormScreenState();
}

class _PromptFormScreenState extends State<PromptFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _topicController = TextEditingController();
  String _selectedPlatform = AppConstants.platforms.first;
  String _selectedTechStack = AppConstants.techStacks['App']!.first;
  bool _shareWithCommunity = false;
  bool _isGenerating = false; // Prevent duplicate submissions

  Stream<int> get _userTokensStream {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(0);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['tokens'] ?? 0);
  }

  @override
  void initState() {
    super.initState();
    print('🔵 [PROMPT FORM] initState() called');

    if (widget.initialProjectName != null) {
      _nameController.text = widget.initialProjectName!;
    }
    if (widget.initialProjectDescription != null) {
      _topicController.text = widget.initialProjectDescription!;
    }
    if (widget.initialPlatform != null) {
      _selectedPlatform = widget.initialPlatform!;
    }
    if (widget.initialTechStack != null) {
      _selectedTechStack = widget.initialTechStack!;
    }

    print(
      '🎯 [PROMPT FORM] Auto-filled: Platform=$_selectedPlatform, Tech=$_selectedTechStack',
    );

    // Reload tokens when screen opens
    print('🔄 [PROMPT FORM] Reloading tokens...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      appProvider.reloadTokens();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _updateTechStackOptions(String platform) {
    setState(() {
      _selectedPlatform = platform;
      _selectedTechStack = AppConstants.techStacks[platform]!.first;
    });
  }

  Future<void> _generatePrompt() async {
    print('🔵 [PROMPT FORM] Generate button clicked!');

    // Prevent duplicate submissions
    if (_isGenerating) {
      print('⚠️ [PROMPT FORM] Already generating, ignoring duplicate click');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      print('❌ [PROMPT FORM] Form validation failed');
      return;
    }

    print('✅ [PROMPT FORM] Form validation passed');

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final tokens = appProvider.tokens;

    print('🪙 [PROMPT FORM] Current tokens from provider: $tokens');
    print('🔍 [PROMPT FORM] Checking if tokens < 1: ${tokens < 1}');

    if (tokens < 1) {
      print('⚠️ [PROMPT FORM] Not enough tokens! Showing NoTokensDialog');
      showDialog(
        context: context,
        builder: (context) => const NoTokensDialog(),
      );
      return;
    }

    print('✅ [PROMPT FORM] Token check passed! Proceeding with generation...');

    // Set generating flag
    setState(() {
      _isGenerating = true;
    });

    final request = PromptRequest(
      projectName: _nameController.text.trim(),
      topic: _topicController.text.trim(),
      platform: _selectedPlatform,
      techStack: _selectedTechStack,
    );

    print('📝 [PROMPT FORM] Request created: ${request.projectName}');

    if (!mounted) {
      print('❌ [PROMPT FORM] Widget not mounted, aborting');
      setState(() {
        _isGenerating = false;
      });
      return;
    }

    // Get streaming service and auth service
    final streamingService = Provider.of<GeminiStreamingService>(
      context,
      listen: false,
    );
    final authService = Provider.of<AuthService>(context, listen: false);

    print('🚀 [PROMPT FORM] Starting streaming generation...');

    // Ensure streaming service has API key
    print('🔑 [PROMPT FORM] Getting API key from Firestore...');
    final userApiKey = await authService.getUserApiKey();
    if (userApiKey == null || userApiKey.isEmpty) {
      print('❌ [PROMPT FORM] No API key found');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API key not found. Please set your API key first.'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          _isGenerating = false;
        });
      }
      return;
    }

    print('🔑 [PROMPT FORM] Initializing streaming service with API key...');
    await streamingService.initialize(apiKey: userApiKey);
    print('✅ [PROMPT FORM] Streaming service initialized');

    // Reload tokens to ensure latest count
    print('🪙 [PROMPT FORM] Reloading tokens...');
    await appProvider.reloadTokens(); // Ensure latest token count

    // Start generation in background and navigate immediately
    final responseStream = streamingService.generatePromptStreaming(request);

    // Token will be deducted after streaming completes and saves to history
    print('ℹ️ [PROMPT FORM] Token will be deducted after generation completes');
    print('🌍 [PROMPT FORM] Share with community: $_shareWithCommunity');

    print('🧭 [PROMPT FORM] Navigating to Streaming Result Screen...');
    if (!mounted) return;

    // Get total phases for this project
    final totalPhases = appProvider.geminiStreamingService.getTotalPhases(
      request,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatResultStreamingScreen(
          projectName: request.projectName,
          responseStream: responseStream,
          request: request,
          shareWithCommunity: _shareWithCommunity,
          totalPhases: totalPhases,
        ),
      ),
    );

    // Reset generating flag when user returns
    if (mounted) {
      setState(() {
        _isGenerating = false;
      });
      // Reload tokens to show updated count
      appProvider.reloadTokens();
    }
    print('✅ [PROMPT FORM] Navigation completed');
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
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  children: [
                    Text(
                      'Create Project',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    StreamBuilder<int>(
                      stream: _userTokensStream,
                      builder: (context, snapshot) {
                        final tokens = snapshot.data ?? 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primaryContainer,
                                colorScheme.secondaryContainer,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Lottie.asset(
                                  'assets/lottie/DevAi.json',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$tokens',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Form Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Project Form Fields
                        ProjectFormFields(
                          nameController: _nameController,
                          topicController: _topicController,
                        ),
                        const SizedBox(height: 32),
                        // Platform Selector
                        PlatformChipSelector(
                          selectedPlatform: _selectedPlatform,
                          onPlatformSelected: _updateTechStackOptions,
                        ),
                        const SizedBox(height: 32),
                        // Tech Stack Selector
                        TechStackChipSelector(
                          selectedPlatform: _selectedPlatform,
                          selectedTechStack: _selectedTechStack,
                          onTechStackSelected: (value) {
                            setState(() {
                              _selectedTechStack = value;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        // Share with Community Toggle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Share with Community',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Let others discover your project',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _shareWithCommunity,
                                onChanged: (value) {
                                  setState(() {
                                    _shareWithCommunity = value;
                                  });
                                },
                                activeTrackColor: colorScheme.primary,
                                activeThumbColor: colorScheme.onPrimary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Generate Button
                        FilledButton(
                          onPressed: _isGenerating ? null : _generatePrompt,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isGenerating)
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 24,
                                ),
                              const SizedBox(width: 12),
                              Text(
                                _isGenerating
                                    ? 'Generating...'
                                    : 'Generate Project',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Lottie.asset(
                                        'assets/lottie/DevAi.json',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '1',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
