import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'dart:math';

import '../constants/app_constants.dart';
import '../models/prompt_response.dart';

class ChatResultScreen extends StatefulWidget {
  final PromptResponse response;
  final String projectName;
  final Future<PromptResponse>? responseFuture;

  const ChatResultScreen({
    super.key,
    required this.response,
    required this.projectName,
  }) : responseFuture = null;

  // Constructor for use with a Future<PromptResponse>
  ChatResultScreen.fromFuture({
    super.key,
    required this.responseFuture,
    required this.projectName,
  }) : response = PromptResponse(
         summary: '',
         techStackExplanation: '',
         features: [],
         uiLayout: '',
         folderStructure: '',
         developmentSteps: [],
       );

  @override
  State<ChatResultScreen> createState() => _ChatResultScreenState();
}

class _ChatResultScreenState extends State<ChatResultScreen> {
  String _currentText = '';
  Timer? _timer;
  int _currentIndex = 0;
  bool _isTyping = true;
  bool _isLoading = false;
  PromptResponse? _response;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.responseFuture != null) {
      _loadResponse();
    } else {
      _response = widget.response;
      _startTypingAnimation();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadResponse() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Loading response from future');
      final response = await widget.responseFuture!;
      print('Response loaded successfully: ${response.summary.substring(0, min(50, response.summary.length))}...');
      
      setState(() {
        _response = response;
        _isLoading = false;
      });
      _startTypingAnimation();
    } catch (e) {
      print('Error loading response in ChatResultScreen: $e');
      print('Error details: ${e.toString()}');
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        // Show error dialog with more details
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error Loading Response'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('An error occurred while loading the response:'),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your prompt was saved successfully, but there was an issue displaying the result. '
                    'You can try again or check your history later.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _startTypingAnimation() {
    final fullText = _formatPrompt();
    const typingSpeed = Duration(
      milliseconds: 10, // Fast typing speed
    );
    const chunkSize = 8; // Increased chunk size for smoother appearance

    _timer = Timer.periodic(typingSpeed, (timer) {
      if (_currentIndex < fullText.length) {
        setState(() {
          final end = (_currentIndex + chunkSize) < fullText.length
              ? _currentIndex + chunkSize
              : fullText.length;
          _currentText = fullText.substring(0, end);
          _currentIndex = end;

          // Scroll immediately without delay for smoother experience
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      } else {
        setState(() => _isTyping = false);
        timer.cancel();
      }
    });
  }

  String _formatPrompt() {
    if (_response == null) return '';

    return '''
# Project Description
${_response!.summary}

# Pages/Screens
${_response!.techStackExplanation}

# Key Features
${_response!.features.map((f) => '- $f').join('\n')}

# UI Design
${_response!.uiLayout}

# Folder Structure
```
${_response!.folderStructure}
```
''';
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _formatPrompt()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _sharePrompt() async {
    await Share.share(_formatPrompt(), subject: 'Dev AI Generated Prompt');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.projectName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isLoading && _response != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.copy, color: colorScheme.primary),
                  onPressed: _copyToClipboard,
                  tooltip: 'Copy to clipboard',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.share, color: colorScheme.primary),
                  onPressed: _sharePrompt,
                  tooltip: 'Share prompt',
                ),
              ),
            ),
          ],
        ],
      ),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
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
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Lottie.asset(
                                  'assets/lottie/DevAi.json',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Generating your project...',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const CircularProgressIndicator(),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Lottie.asset(
                                      'assets/lottie/DevAi.json',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Dev AI',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (_isTyping) ...[
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Generating...',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  100,
                                ), // Extra bottom padding
                                physics: const BouncingScrollPhysics(),
                                child: MarkdownBody(
                                  data: _currentText,
                                  styleSheet: MarkdownStyleSheet(
                                    p: AppConstants.monoTextStyle.copyWith(
                                      height: 1.5,
                                    ),
                                    code: AppConstants.monoTextStyle.copyWith(
                                      backgroundColor:
                                          colorScheme.surfaceVariant,
                                      height: 1.5,
                                    ),
                                    codeblockDecoration: BoxDecoration(
                                      color: colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    h1: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                      height: 2,
                                    ),
                                    listBullet: TextStyle(
                                      color: colorScheme.primary,
                                      height: 1.5,
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
        ),
      ),
    );
  }
}
