import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class LoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  int _currentMessageIndex = 0;
  Timer? _timer;

  final List<String> _messages = [
    'Analyzing your requirements...',
    'Designing project architecture...',
    'Creating UI design system...',
    'Generating folder structure...',
    'Selecting best packages...',
    'Planning testing strategy...',
    'Defining acceptance criteria...',
    'Building development roadmap...',
    'Almost there...',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) {
      _startMessageRotation();
    }
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _startMessageRotation();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _stopMessageRotation();
    }
  }

  @override
  void dispose() {
    _stopMessageRotation();
    super.dispose();
  }

  void _startMessageRotation() {
    _currentMessageIndex = 0;
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _messages.length;
        });
      }
    });
  }

  void _stopMessageRotation() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Lottie
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.3),
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
                    // Main message
                    Text(
                      widget.message ?? 'Generating Project...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Rotating progress message
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _messages[_currentMessageIndex],
                        key: ValueKey<int>(_currentMessageIndex),
                        style: TextStyle(
                          fontSize: 15,
                          color: colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Progress indicator
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: colorScheme.surface.withValues(
                          alpha: 0.3,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This may take 30-60 seconds',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
