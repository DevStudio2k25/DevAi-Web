import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../constants/app_constants.dart';
import '../models/prompt_response.dart';
import 'dart:async';

class PromptCard extends StatefulWidget {
  final PromptResponse response;
  final VoidCallback? onShare;
  final bool showTypingAnimation;

  const PromptCard({
    super.key,
    required this.response,
    this.onShare,
    this.showTypingAnimation = true,
  });

  @override
  State<PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<PromptCard> {
  String _currentText = '';
  Timer? _timer;
  int _currentIndex = 0;
  bool _isTyping = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.showTypingAnimation) {
      _startTypingAnimation();
    } else {
      _currentText = _formatPrompt();
      _isTyping = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startTypingAnimation() {
    final fullText = _formatPrompt();
    const typingSpeed = Duration(milliseconds: 10);
    const chunkSize = 6;

    _timer = Timer.periodic(typingSpeed, (timer) {
      if (_currentIndex < fullText.length) {
        setState(() {
          final end = (_currentIndex + chunkSize) < fullText.length
              ? _currentIndex + chunkSize
              : fullText.length;
          _currentText = fullText.substring(0, end);
          _currentIndex = end;

          Timer(const Duration(milliseconds: 5), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 50),
                curve: Curves.easeOut,
              );
            }
          });
        });
      } else {
        setState(() => _isTyping = false);
        timer.cancel();
      }
    });
  }

  String _formatPrompt() {
    return '''
# Project Description
${widget.response.summary}

# Pages/Screens
${widget.response.techStackExplanation}

# Key Features
${widget.response.features.map((f) => '- $f').join('\n')}

# UI Design
${widget.response.uiLayout}

# Folder Structure
```
${widget.response.folderStructure}
```
''';
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _formatPrompt()));
    if (context.mounted) {
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

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.code, color: colorScheme.primary, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Dev AI',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isTyping) ...[
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(context),
                      tooltip: 'Copy to clipboard',
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: _sharePrompt,
                      tooltip: 'Share prompt',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: MarkdownBody(
                data: _currentText,
                styleSheet: MarkdownStyleSheet(
                  p: AppConstants.monoTextStyle.copyWith(height: 1.5),
                  code: AppConstants.monoTextStyle.copyWith(
                    backgroundColor: colorScheme.surfaceVariant,
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
    );
  }
}
