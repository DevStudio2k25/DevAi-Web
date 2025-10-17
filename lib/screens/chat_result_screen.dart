// ignore_for_file: avoid_print

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
      print(
        'Response loaded successfully: ${response.summary.substring(0, min(50, response.summary.length))}...',
      );

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
      milliseconds: 1, // Double speed for history (was 10ms)
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

    final buffer = StringBuffer();

    // Always show Project Overview (summary)
    buffer.writeln('# Project Overview');
    buffer.writeln(_response!.summary);
    buffer.writeln();

    // Only show other sections if they have content
    if (_response!.techStackExplanation.isNotEmpty) {
      buffer.writeln('# Pages/Screens');
      buffer.writeln(_response!.techStackExplanation);
      buffer.writeln();
    }

    if (_response!.features.isNotEmpty) {
      buffer.writeln('# Key Features');
      buffer.writeln(_response!.features.map((f) => '- $f').join('\n'));
      buffer.writeln();
    }

    if (_response!.uiLayout.isNotEmpty) {
      buffer.writeln('# UI Design System');
      buffer.writeln(_response!.uiLayout);
      buffer.writeln();
    }

    if (_response!.folderStructure.isNotEmpty) {
      buffer.writeln('# Architecture & Folder Structure');
      buffer.writeln('```');
      buffer.writeln(_response!.folderStructure);
      buffer.writeln('```');
      buffer.writeln();
    }

    if (_response!.recommendedPackages != null) {
      buffer.writeln('# Recommended Packages');
      buffer.writeln(_response!.recommendedPackages);
      buffer.writeln();
    }

    if (_response!.nonFunctionalRequirements != null) {
      buffer.writeln('# Non-Functional Requirements');
      buffer.writeln(_response!.nonFunctionalRequirements);
      buffer.writeln();
    }

    if (_response!.testingStrategy != null) {
      buffer.writeln('# Testing Strategy');
      buffer.writeln(_response!.testingStrategy);
      buffer.writeln();
    }

    if (_response!.acceptanceCriteria != null) {
      buffer.writeln('# Acceptance Criteria (MVP)');
      buffer.writeln(_response!.acceptanceCriteria);
      buffer.writeln();
    }

    if (_response!.developmentRoadmap != null) {
      buffer.writeln('# Development Roadmap');
      buffer.writeln(_response!.developmentRoadmap);
      buffer.writeln();
    }

    return buffer.toString();
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
            controller: _scrollController,
            slivers: [
              // Modern App Bar
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  widget.projectName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                actions: [
                  if (!_isLoading && _response != null) ...[
                    IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        color: colorScheme.primary,
                      ),
                      onPressed: _copyToClipboard,
                      tooltip: 'Copy to clipboard',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.share_rounded,
                        color: colorScheme.primary,
                      ),
                      onPressed: _sharePrompt,
                      tooltip: 'Share',
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
              // Content
              if (_isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primaryContainer.withValues(
                                  alpha: 0.5,
                                ),
                                colorScheme.secondaryContainer.withValues(
                                  alpha: 0.5,
                                ),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Lottie.asset(
                              'assets/lottie/DevAi.json',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Generating your project...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This may take a few moments',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        CircularProgressIndicator(color: colorScheme.primary),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primaryContainer,
                                  colorScheme.secondaryContainer,
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
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
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DevAi Generated',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      if (_isTyping)
                                        Text(
                                          'Generating...',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            color: colorScheme
                                                .onPrimaryContainer
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: MarkdownBody(
                              data: _currentText,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: colorScheme.onSurface,
                                ),
                                code: AppConstants.monoTextStyle.copyWith(
                                  backgroundColor:
                                      colorScheme.surfaceContainerHighest,
                                  color: colorScheme.onSurface,
                                  height: 1.5,
                                ),
                                codeblockDecoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                codeblockPadding: const EdgeInsets.all(16),
                                h1: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  height: 2,
                                ),
                                h2: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  height: 1.8,
                                ),
                                h3: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                  height: 1.6,
                                ),
                                listBullet: TextStyle(
                                  color: colorScheme.primary,
                                  height: 1.6,
                                ),
                                listIndent: 24,
                                blockquote: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                                blockquoteDecoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border(
                                    left: BorderSide(
                                      color: colorScheme.primary,
                                      width: 4,
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
              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
