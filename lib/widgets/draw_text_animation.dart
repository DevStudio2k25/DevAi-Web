import 'package:flutter/material.dart';

/// A widget that animates text with a handwriting-style stroke effect.
/// The text appears as if being drawn stroke by stroke.
class DrawTextAnimation extends StatefulWidget {
  final String text;
  final Duration duration;
  final Color strokeColor;
  final double strokeWidth;
  final TextStyle textStyle;
  final VoidCallback? onFinish;

  const DrawTextAnimation({
    super.key,
    required this.text,
    this.duration = const Duration(seconds: 2),
    this.strokeColor = Colors.white,
    this.strokeWidth = 3.0,
    required this.textStyle,
    this.onFinish,
  });

  @override
  State<DrawTextAnimation> createState() => _DrawTextAnimationState();
}

class _DrawTextAnimationState extends State<DrawTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Create curved animation for smooth easing
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Listen for animation updates to trigger repaints
    _animation.addListener(() {
      setState(() {});
    });

    // Listen for animation completion
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinish?.call();
      }
    });

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TextStrokePainter(
        text: widget.text,
        textStyle: widget.textStyle,
        strokeColor: widget.strokeColor,
        strokeWidth: widget.strokeWidth,
        progress: _animation.value,
      ),
      child: SizedBox(
        // Calculate size based on text
        width: _calculateTextWidth(),
        height: _calculateTextHeight(),
      ),
    );
  }

  double _calculateTextWidth() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  double _calculateTextHeight() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.height;
  }
}

/// Custom painter that draws text with a progressive stroke animation.
/// Uses character-by-character reveal with stroke effect for authentic drawing appearance.
class TextStrokePainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final Color strokeColor;
  final double strokeWidth;
  final double progress;

  TextStrokePainter({
    required this.text,
    required this.textStyle,
    required this.strokeColor,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate how many characters to show based on progress
    final totalChars = text.length;
    final charsToShow = (totalChars * progress).ceil().clamp(0, totalChars);

    if (charsToShow == 0) return;

    // Create text painter for measuring and drawing
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw each character with stroke effect
    double xOffset = 0;

    for (int i = 0; i < charsToShow; i++) {
      final char = text[i];
      final charProgress = _calculateCharProgress(i, charsToShow, totalChars);

      // Create text span for this character
      textPainter.text = TextSpan(text: char, style: textStyle);
      textPainter.layout();

      // Draw stroke (outline)
      if (charProgress > 0) {
        _drawCharacterStroke(
          canvas,
          textPainter,
          Offset(xOffset, 0),
          charProgress,
        );
      }

      // Draw fill (solid text) after stroke is mostly drawn
      if (charProgress > 0.7) {
        _drawCharacterFill(
          canvas,
          textPainter,
          Offset(xOffset, 0),
          (charProgress - 0.7) / 0.3, // Fade in fill
        );
      }

      xOffset += textPainter.width;
    }
  }

  /// Calculate progress for individual character (0.0 to 1.0)
  double _calculateCharProgress(
    int charIndex,
    int charsToShow,
    int totalChars,
  ) {
    if (charIndex < charsToShow - 1) {
      return 1.0; // Fully drawn
    } else if (charIndex == charsToShow - 1) {
      // Current character being drawn
      final charProgress = (progress * totalChars) - charIndex;
      return charProgress.clamp(0.0, 1.0);
    }
    return 0.0;
  }

  /// Draw character stroke (outline)
  void _drawCharacterStroke(
    Canvas canvas,
    TextPainter textPainter,
    Offset offset,
    double charProgress,
  ) {
    final strokePaint = Paint()
      ..color = strokeColor.withOpacity(charProgress.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Save canvas state
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    // Draw text with stroke
    textPainter.paint(canvas, Offset.zero);

    // Apply stroke effect by drawing outline
    final textSpan = textPainter.text as TextSpan;
    final outlineTextPainter = TextPainter(
      text: TextSpan(
        text: textSpan.text,
        style: textSpan.style?.copyWith(foreground: strokePaint),
      ),
      textDirection: TextDirection.ltr,
    );
    outlineTextPainter.layout();
    outlineTextPainter.paint(canvas, Offset.zero);

    canvas.restore();
  }

  /// Draw character fill (solid color)
  void _drawCharacterFill(
    Canvas canvas,
    TextPainter textPainter,
    Offset offset,
    double fillProgress,
  ) {
    final fillPaint = Paint()
      ..color = strokeColor.withOpacity(fillProgress.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final textSpan = textPainter.text as TextSpan;
    final fillTextPainter = TextPainter(
      text: TextSpan(
        text: textSpan.text,
        style: textSpan.style?.copyWith(foreground: fillPaint),
      ),
      textDirection: TextDirection.ltr,
    );
    fillTextPainter.layout();
    fillTextPainter.paint(canvas, Offset.zero);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TextStrokePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.text != text ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
