// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../constants/app_constants.dart';
import '../models/prompt_request.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import '../widgets/inline_color_palette_widget.dart';

class ChatResultStreamingScreen extends StatefulWidget {
  final String projectName;
  final Stream<String> responseStream;
  final PromptRequest? request;
  final bool shareWithCommunity;
  final int totalPhases; // Total phases for this project

  const ChatResultStreamingScreen({
    super.key,
    required this.projectName,
    required this.responseStream,
    this.request,
    this.shareWithCommunity = false,
    this.totalPhases = 10, // Default to 10
  });

  @override
  State<ChatResultStreamingScreen> createState() =>
      _ChatResultStreamingScreenState();
}

class _ChatResultStreamingScreenState extends State<ChatResultStreamingScreen> {
  final ScrollController _scrollController = ScrollController();
  String _fullText = '';
  String _displayText = ''; // For typing effect
  Map<String, String> _customColors = {}; // Store customized colors
  Map<String, String> _extractedColors = {}; // Extracted from design phase
  bool _showColorPalette = false; // Show palette only for design phase
  int _currentPhase = 0;
  bool _isComplete = false;
  bool _isSaved = false;
  bool _isShared = false;
  bool _isGenerating = false;
  bool _waitingForContinue = false;
  bool _isTyping = false;
  bool _isRetrying = false;
  int _retryCountdown = 0;
  Timer? _countdownTimer;
  StreamSubscription? _subscription;
  StreamIterator<String>? _streamIterator;
  Timer? _typingTimer;
  int _typingIndex = 0;

  final Map<int, String> _allPhaseNames = {
    1: 'Project Overview',
    2: 'Pages/Screens',
    3: 'Key Features',
    4: 'UI Design System',
    5: 'Architecture & Folder Structure',
    6: 'Recommended Packages',
    7: 'Non-Functional Requirements',
    8: 'Testing Strategy',
    9: 'Acceptance Criteria (MVP)',
    10: 'Development Roadmap',
  };

  List<String> get _phaseNames {
    // Get selected phases from service if available
    if (widget.request != null) {
      try {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        final selectedPhases = appProvider.geminiStreamingService
            .getSelectedPhases(widget.request!);
        return selectedPhases
            .map((p) => _allPhaseNames[p] ?? 'Phase $p')
            .toList();
      } catch (e) {
        // Fallback to all phases
      }
    }
    return _allPhaseNames.values.toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _streamIterator?.cancel();
    _typingTimer?.cancel();
    _countdownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _extractColorsFromContent(String content) {
    final colorRegex = RegExp(r'#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})');
    final Map<String, String> colors = {};
    final lines = content.split('\n');

    for (var line in lines) {
      final lowerLine = line.toLowerCase();
      final match = colorRegex.firstMatch(line);

      if (match != null) {
        final colorCode = match.group(0)!;

        if (lowerLine.contains('primary')) {
          colors['Primary'] = colorCode;
        } else if (lowerLine.contains('secondary')) {
          colors['Secondary'] = colorCode;
        } else if (lowerLine.contains('success')) {
          colors['Success'] = colorCode;
        } else if (lowerLine.contains('warning')) {
          colors['Warning'] = colorCode;
        } else if (lowerLine.contains('error') ||
            lowerLine.contains('danger')) {
          colors['Error'] = colorCode;
        } else if (lowerLine.contains('background')) {
          colors['Background'] = colorCode;
        } else if (lowerLine.contains('surface')) {
          colors['Surface'] = colorCode;
        } else if (lowerLine.contains('text')) {
          colors['Text'] = colorCode;
        }
      }
    }

    if (colors.isNotEmpty) {
      setState(() {
        _extractedColors = colors;
        _showColorPalette = true;
      });
      print('🎨 [COLORS] Extracted ${colors.length} colors: $colors');
    }
  }

  void _updateColorsInMarkdown(Map<String, String> newColors) {
    String updatedText = _fullText;

    // Replace each color in the markdown
    newColors.forEach((colorName, newHex) {
      final lines = updatedText.split('\n');
      for (int i = 0; i < lines.length; i++) {
        final lowerLine = lines[i].toLowerCase();
        if (lowerLine.contains(colorName.toLowerCase())) {
          // Replace the hex code in this line
          final colorRegex = RegExp(r'#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})');
          lines[i] = lines[i].replaceFirstMapped(colorRegex, (match) => newHex);
        }
      }
      updatedText = lines.join('\n');
    });

    setState(() {
      _fullText = updatedText;
      _displayText = updatedText;
    });

    print('🎨 [MARKDOWN] Updated colors in markdown content');
  }

  void _startTypingEffect(String newChunk) {
    print('⌨️ [TYPING] Starting typing effect for ${newChunk.length} chars');

    _typingTimer?.cancel();
    _typingIndex = _displayText.length;
    _fullText += newChunk;

    // Check if this is design phase (Phase 4)
    if (newChunk.contains('# 4.') ||
        newChunk.contains('UI Design System') ||
        newChunk.contains('Color Palette')) {
      _extractColorsFromContent(newChunk);
      print('🎨 [DESIGN] Design phase detected, extracting colors');
    }

    setState(() {
      _isTyping = true;
    });

    const typingSpeed = Duration(milliseconds: 10);
    const chunkSize = 8;

    _typingTimer = Timer.periodic(typingSpeed, (timer) {
      if (_typingIndex < _fullText.length) {
        setState(() {
          final end = (_typingIndex + chunkSize) < _fullText.length
              ? _typingIndex + chunkSize
              : _fullText.length;
          _displayText = _fullText.substring(0, end);
          _typingIndex = end;
        });

        // Auto-scroll
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      } else {
        timer.cancel();

        // Increment phase first
        final completedPhase = _currentPhase + 1;
        print('✅ [TYPING] Typing complete for phase $completedPhase');

        // Update all states together in one setState
        setState(() {
          _isTyping = false;
          _currentPhase = completedPhase;

          // Check if more phases remaining
          if (_currentPhase < widget.totalPhases) {
            _waitingForContinue = true;
            print(
              '⏸️ [TYPING] Waiting for user to continue to phase ${_currentPhase + 1}...',
            );
          } else {
            // Last phase complete
            _isComplete = true;
            print(
              '🎉 [TYPING] Last phase typing complete, marking as complete',
            );
          }
        });

        // Save to history if complete (outside setState)
        if (_isComplete) {
          _saveToHistory();
        }
      }
    });
  }

  void _waitForTypingThenComplete() {
    // Check periodically if typing is done
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isTyping) {
        timer.cancel();
        print('🎉 [COMPLETE] Typing finished, marking as complete');
        setState(() {
          _isComplete = true;
        });
        _saveToHistory();
      }
    });
  }

  void _onContinuePressed() {
    print('▶️ [STREAMING SCREEN] User clicked Continue');
    _generateNextPhase();
  }

  Future<void> _onRetryPressed() async {
    if (_isRetrying || widget.request == null) return;

    setState(() {
      _isRetrying = true;
      _retryCountdown = 20;
    });

    // Start countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _retryCountdown--;
      });

      if (_retryCountdown <= 0) {
        timer.cancel();
      }
    });

    try {
      print('🔄 [RETRY] Retrying current phase: $_currentPhase');

      // Get services
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final service = appProvider.geminiStreamingService;

      // Ensure API key is initialized
      print('🔑 [RETRY] Ensuring API key is initialized...');
      final authService = Provider.of<AuthService>(context, listen: false);
      final apiKey = await authService.getUserApiKey();

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please check your settings.');
      }

      await service.initialize(apiKey: apiKey);
      print('✅ [RETRY] API key initialized successfully');

      // Retry current phase
      final newContent = await service.retryPhase(
        widget.request!,
        _currentPhase,
      );

      // Replace last phase content in fullText
      final sections = _fullText.split('\n\n');
      if (sections.isNotEmpty) {
        sections.removeLast(); // Remove failed section
        _fullText = sections.join('\n\n') + '\n\n$newContent\n\n';
        _displayText = _fullText;
      }

      setState(() {
        _isRetrying = false;
        _retryCountdown = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Phase regenerated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRetrying = false;
        _retryCountdown = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Retry failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _initializeStream() async {
    print('🎧 [STREAMING SCREEN] Initializing stream iterator');
    _streamIterator = StreamIterator(widget.responseStream);

    // Generate first phase automatically
    _generateNextPhase();
  }

  Future<void> _generateNextPhase() async {
    if (_streamIterator == null || _isComplete) return;

    setState(() {
      _isGenerating = true;
      _waitingForContinue = false;
    });

    print(
      '🔄 [STREAMING SCREEN] Generating phase ${_currentPhase + 1}/${widget.totalPhases}',
    );

    try {
      final hasNext = await _streamIterator!.moveNext();

      if (hasNext) {
        final chunk = _streamIterator!.current;
        print('📥 [STREAMING SCREEN] Received chunk: ${chunk.length} chars');

        setState(() {
          _isGenerating = false;
        });

        // Start typing effect - phase will increment after typing completes
        _startTypingEffect(chunk);
      } else {
        print('✅ [STREAMING SCREEN] Stream ended');
        setState(() {
          _isGenerating = false;
        });

        // Wait for typing to complete before marking as complete
        _waitForTypingThenComplete();
      }
    } catch (error) {
      print('❌ [STREAMING SCREEN] Error: $error');
      setState(() {
        _fullText += '\n\n# Error\n\nFailed to generate: $error';
        _isComplete = true;
        _isGenerating = false;
      });
    }
  }

  String _applyCustomColors(String content, Map<String, String> customColors) {
    String updatedContent = content;

    // Replace each color in the content
    customColors.forEach((colorName, newHex) {
      // Find and replace color codes in the design phase section
      final colorRegex = RegExp(r'#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})');
      final lines = updatedContent.split('\n');

      for (int i = 0; i < lines.length; i++) {
        if (lines[i].toLowerCase().contains(colorName.toLowerCase())) {
          lines[i] = lines[i].replaceAllMapped(colorRegex, (match) => newHex);
        }
      }

      updatedContent = lines.join('\n');
    });

    return updatedContent;
  }

  Future<void> _saveToHistory() async {
    if (widget.request == null) {
      print('⚠️ [SAVE] No request provided, cannot save');
      return;
    }

    if (_isSaved) {
      print('⚠️ [SAVE] Already saved, skipping');
      return;
    }

    print('💾 [SAVE] Starting save to history...');

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);

      // Apply custom colors to content if any
      String finalContent = _fullText;
      if (_customColors.isNotEmpty) {
        print('🎨 [SAVE] Applying ${_customColors.length} custom colors');
        finalContent = _applyCustomColors(_fullText, _customColors);
      }

      // Use the new streaming save method
      final result = await appProvider.saveStreamingResult(
        widget.request!,
        finalContent,
        shareWithCommunity: widget.shareWithCommunity,
      );

      print('📊 [SAVE] Save result: $result');

      setState(() {
        _isSaved = result['saved'] ?? false;
        _isShared = result['shared'] ?? false;
      });

      if (_isSaved) {
        print('✅ [SAVE] Successfully saved to history');
      }
      if (_isShared) {
        print('✅ [SAVE] Successfully shared with community');
      }
    } catch (e) {
      print('❌ [SAVE] Error saving to history: $e');
      print('❌ [SAVE] Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _fullText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Content copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareContent() async {
    await Share.share(
      _fullText,
      subject: 'DevAi Generated: ${widget.projectName}',
    );
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
          child: Stack(
            children: [
              // Scrollable Content
              CustomScrollView(
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
                      if (_isComplete) ...[
                        IconButton(
                          icon: Icon(
                            Icons.copy_rounded,
                            color: colorScheme.primary,
                          ),
                          onPressed: _copyToClipboard,
                          tooltip: 'Copy',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.share_rounded,
                            color: colorScheme.primary,
                          ),
                          onPressed: _shareContent,
                          tooltip: 'Share',
                        ),
                      ],
                      const SizedBox(width: 8),
                    ],
                  ),
                  // Content (Progress moved to bottom)
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
                                            color:
                                                colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                        if (!_isComplete)
                                          Text(
                                            'Generating in real-time...',
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
                              child: _displayText.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(colorScheme.primary),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Starting generation...',
                                              style: TextStyle(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : MarkdownBody(
                                      data: _displayText,
                                      styleSheet: MarkdownStyleSheet(
                                        p: TextStyle(
                                          fontSize: 15,
                                          height: 1.6,
                                          color: colorScheme.onSurface,
                                        ),
                                        code: AppConstants.monoTextStyle
                                            .copyWith(
                                              backgroundColor: colorScheme
                                                  .surfaceContainerHighest,
                                              color: colorScheme.onSurface,
                                              height: 1.5,
                                            ),
                                        codeblockDecoration: BoxDecoration(
                                          color: colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.outline
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        codeblockPadding: const EdgeInsets.all(
                                          16,
                                        ),
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
                                      ),
                                    ),
                            ),
                            // Inline Color Palette (only for design phase)
                            if (_showColorPalette &&
                                _extractedColors.isNotEmpty &&
                                !_isTyping)
                              InlineColorPaletteWidget(
                                colors: _extractedColors,
                                onColorsChanged: (colors) {
                                  setState(() {
                                    _customColors = colors;
                                    _extractedColors = colors;
                                  });

                                  // Update the actual markdown content
                                  _updateColorsInMarkdown(colors);

                                  print('🎨 [COLORS] Updated: $colors');

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '✨ Colors updated! Changes will be saved.',
                                          ),
                                        ],
                                      ),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: Colors.green.shade600,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom spacing (for fixed card)
                  const SliverToBoxAdapter(child: SizedBox(height: 180)),
                ],
              ),
              // Fixed Bottom Progress Card - Always visible during generation
              if (_isGenerating ||
                  _waitingForContinue ||
                  _isTyping ||
                  _isComplete)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
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
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            if (_isGenerating || _isTyping)
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.check_circle_rounded,
                                color: _isComplete
                                    ? Colors.green
                                    : colorScheme.primary,
                                size: 24,
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isComplete
                                    ? 'Generation Completed!'
                                    : (_isGenerating || _isTyping)
                                    ? 'Generating Phase ${_currentPhase + 1}/${widget.totalPhases}...'
                                    : 'Phase $_currentPhase Complete!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _isComplete
                                      ? Colors.green.shade700
                                      : colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _currentPhase / widget.totalPhases,
                          backgroundColor: colorScheme.surface.withValues(
                            alpha: 0.3,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isComplete ? Colors.green : colorScheme.primary,
                          ),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentPhase >= 0 &&
                                  _currentPhase < widget.totalPhases
                              ? (_isGenerating || _isTyping)
                                    ? '${_phaseNames[_currentPhase]} ⏳' // Show current generating phase
                                    : _currentPhase > 0
                                    ? '${_phaseNames[_currentPhase - 1]} ✓' // Show completed phase
                                    : 'Starting...'
                              : _isComplete
                              ? '${_phaseNames.isNotEmpty ? _phaseNames[_phaseNames.length - 1] : "Complete"} ✓' // Show last phase when complete
                              : 'Starting...',
                          style: TextStyle(
                            fontSize: 13,
                            color: _isComplete
                                ? Colors.green.shade700
                                : colorScheme.onPrimaryContainer.withValues(
                                    alpha: 0.7,
                                  ),
                          ),
                        ),
                        if (_isComplete) ...[
                          const SizedBox(height: 12),
                          if (_isSaved)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.save_rounded,
                                  size: 16,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Saved to History',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          if (_isShared) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.public_rounded,
                                  size: 16,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Shared with Community',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                        if (_waitingForContinue &&
                            !_isTyping &&
                            !_isRetrying) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Continue Button
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _onContinuePressed,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 24,
                                  ),
                                  label: Text(
                                    'Continue (${_currentPhase + 1}/${widget.totalPhases})',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Retry Button
                              FilledButton.icon(
                                onPressed: _onRetryPressed,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                ),
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 22,
                                ),
                                label: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Retry in progress
                        if (_isRetrying) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: null,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            icon: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white70,
                                ),
                              ),
                            ),
                            label: Text(
                              _retryCountdown > 0
                                  ? 'Retrying in ${_retryCountdown}s...'
                                  : 'Regenerating...',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (_isTyping) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: null, // Disabled during typing
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            icon: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white70,
                                ),
                              ),
                            ),
                            label: const Text(
                              'Generating...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
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
