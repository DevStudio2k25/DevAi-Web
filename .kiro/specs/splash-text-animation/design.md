# Design Document

## Overview

This design document outlines the implementation of a handwriting-style text stroke animation for the DevAi splash screen. The feature will use the `drawing_animation` package to create a draw-style effect where the app name "DevAi" appears as if being written stroke by stroke. The animation will integrate seamlessly with the existing splash screen animations, maintaining the current timing structure while enhancing visual appeal.

## Architecture

### Component Structure

```
SplashScreen (existing)
├── AnimationController (existing - extended)
├── Logo Animations (existing - unchanged)
├── DrawTextAnimation Widget (new)
│   └── AnimatedDrawing or Custom Path Animation
├── Tagline Animation (existing - unchanged)
└── Loading Indicator (existing - unchanged)
```

### Animation Timeline (8 seconds total)

```
0s ────────── 2s ────────── 4s ────────── 6s ────────── 8s
│              │              │              │              │
│   Logo       │   Text       │   Tagline    │   Pulse +    │
│   Fade +     │   Stroke     │   Fade       │   Navigate   │
│   Scale      │   Drawing    │              │              │
```

- **0-2s (0.0-0.25)**: Logo fade in and scale (existing)
- **2-4s (0.25-0.5)**: Text stroke drawing animation (new - replaces fade/slide)
- **4-6s (0.5-0.75)**: Tagline fade in (existing)
- **6-8s (0.75-1.0)**: Pulse animation and navigation (existing)

## Components and Interfaces

### 1. DrawTextAnimation Widget

A custom widget that wraps the text stroke animation functionality.

**Properties:**
- `text`: String - The text to animate ("DevAi")
- `duration`: Duration - Animation duration (2 seconds)
- `strokeColor`: Color - Color of the drawing stroke (white)
- `strokeWidth`: double - Width of the stroke line (3.0)
- `fontSize`: double - Size of the text (48)
- `fontWeight`: FontWeight - Weight of the font (bold)
- `letterSpacing`: double - Spacing between letters (2.0)
- `onFinish`: VoidCallback? - Callback when animation completes

**Implementation Approach:**

Since `drawing_animation` package primarily works with SVG paths, we have two options:

#### Option A: Custom Path-Based Animation (Recommended)
Create a custom implementation using Flutter's `CustomPainter` and `Path` to draw text strokes:

```dart
class DrawTextAnimation extends StatefulWidget {
  final String text;
  final Duration duration;
  final Color strokeColor;
  final double strokeWidth;
  final TextStyle textStyle;
  final VoidCallback? onFinish;
  
  // Constructor and state...
}

class _DrawTextAnimationState extends State<DrawTextAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Animation setup and path extraction...
}

class TextPathPainter extends CustomPainter {
  final Path path;
  final double progress;
  final Color strokeColor;
  final double strokeWidth;
  
  // Paint the text path progressively...
}
```

#### Option B: Character-by-Character Reveal
Animate text appearance character by character with a typewriter effect combined with fade-in:

```dart
class DrawTextAnimation extends StatefulWidget {
  // Similar properties...
}

class _DrawTextAnimationState extends State<DrawTextAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentCharIndex = 0;
  
  // Reveal characters progressively with fade effect...
}
```

**Chosen Approach:** Option A (Custom Path-Based Animation) provides the most authentic "drawing" effect and aligns with the user's request for stroke-based animation.

### 2. Integration with SplashScreen

**Modified Animation Structure:**

```dart
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeLogoAnimation;
  late Animation<double> _scaleLogoAnimation;
  late Animation<double> _textDrawAnimation; // NEW
  late Animation<double> _fadeTaglineAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _showDrawnText = false; // NEW - trigger text animation
  
  // Animation setup...
}
```

**Animation Intervals:**
- Logo: 0.0 - 0.25 (unchanged)
- Text Drawing: 0.25 - 0.5 (new)
- Tagline: 0.5 - 0.75 (unchanged)
- Pulse: 0.75 - 1.0 (unchanged)

### 3. Text Path Extraction

To animate text strokes, we need to extract the path from the text:

```dart
Path _getTextPath(String text, TextStyle style) {
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  
  // Extract outline path from text
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  textPainter.paint(canvas, Offset.zero);
  
  // Convert to path using path extraction technique
  // This requires custom implementation or helper package
  return extractedPath;
}
```

**Note:** Flutter doesn't provide direct text-to-path conversion. We'll use a pragmatic approach with `CustomPainter` to draw text outlines progressively.

## Data Models

No new data models required. The feature uses existing Flutter animation primitives and widget state.

## Error Handling

### Animation Failures

**Scenario:** Animation controller fails to initialize or animate
- **Handling:** Fallback to static text display with fade-in
- **User Impact:** Graceful degradation - text still appears, just without stroke animation

**Scenario:** Path extraction fails or produces invalid paths
- **Handling:** Use fallback character-by-character reveal animation
- **User Impact:** Different animation style but still visually appealing

### Performance Issues

**Scenario:** Animation causes frame drops on low-end devices
- **Handling:** Reduce animation complexity or duration
- **Mitigation:** Test on various devices and optimize path complexity

### Resource Cleanup

**Scenario:** Animation resources not properly disposed
- **Handling:** Ensure all controllers and painters are disposed in `dispose()` method
- **Prevention:** Follow Flutter lifecycle best practices

## Testing Strategy

### Unit Tests

1. **Animation Controller Tests**
   - Verify animation intervals are correctly configured
   - Test animation completion callbacks
   - Validate timing calculations

2. **Widget Tests**
   - Test DrawTextAnimation widget renders correctly
   - Verify animation state transitions
   - Test callback invocations

### Integration Tests

1. **Splash Screen Flow**
   - Verify complete animation sequence (logo → text → tagline → pulse)
   - Test navigation occurs after animation completion
   - Validate animation timing coordination

2. **Theme Integration**
   - Test stroke color adapts to theme
   - Verify contrast against gradient background
   - Test in both light and dark themes (if applicable)

### Visual Tests

1. **Animation Smoothness**
   - Manual testing on physical devices
   - Verify 60fps performance
   - Check for visual glitches or artifacts

2. **Cross-Device Testing**
   - Test on various screen sizes
   - Verify text scaling and positioning
   - Test on different Android versions

### Performance Tests

1. **Frame Rate Monitoring**
   - Use Flutter DevTools to monitor frame rendering
   - Ensure no jank during animation
   - Profile memory usage

2. **Resource Usage**
   - Monitor CPU usage during animation
   - Check memory allocation and cleanup
   - Verify no memory leaks

## Implementation Notes

### Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  # Existing dependencies...
  path_drawing: ^1.0.1  # For path manipulation if needed
```

**Note:** The `drawing_animation` package mentioned in the user's request is primarily for SVG animations. For text stroke animation, we'll implement a custom solution using Flutter's built-in `CustomPainter` and animation APIs, which provides more control and better integration with the existing codebase.

### Alternative Approach: Simplified Implementation

If path-based animation proves too complex, implement a simpler "reveal" effect:

1. Draw text outline with stroke
2. Animate a clipping mask from left to right
3. Gradually reveal the text with a drawing effect

This provides a similar visual impact with less complexity.

### Styling Considerations

- **Stroke Color:** White with slight transparency (0.9-1.0 alpha) for visibility against gradient
- **Stroke Width:** 3.0 for clear visibility without being too bold
- **Font:** Use existing theme font (Google Fonts Roboto) with bold weight
- **Shadows:** Add subtle shadow for depth, matching existing text styling

### Accessibility

- Animation should not be required for app functionality
- Consider adding a reduced motion preference check
- Ensure text is readable throughout animation

## Design Decisions and Rationales

### Decision 1: Custom Implementation vs. Package

**Decision:** Use custom `CustomPainter` implementation instead of `drawing_animation` package

**Rationale:**
- `drawing_animation` is designed for SVG paths, not text
- Custom implementation provides better control over styling and timing
- Reduces external dependencies
- Better integration with existing animation controller
- More maintainable and customizable

### Decision 2: Replace Fade/Slide with Stroke Animation

**Decision:** Replace existing text fade and slide animations with stroke drawing

**Rationale:**
- Provides more visual interest and uniqueness
- Aligns with user's request for handwriting-style effect
- Maintains same timing slot (2-4s) in animation sequence
- Creates a signature/logo-like effect appropriate for branding

### Decision 3: Single Animation Controller

**Decision:** Extend existing animation controller rather than creating separate controller

**Rationale:**
- Maintains timing synchronization with other animations
- Reduces complexity and resource usage
- Easier to coordinate animation sequence
- Consistent with existing architecture

### Decision 4: Graceful Degradation

**Decision:** Implement fallback to simple fade-in if stroke animation fails

**Rationale:**
- Ensures app always displays properly
- Handles edge cases and errors gracefully
- Maintains user experience even on low-end devices
- Follows Flutter best practices for robust UI
