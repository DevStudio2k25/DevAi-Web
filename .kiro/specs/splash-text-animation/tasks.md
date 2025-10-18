# Implementation Plan

- [x] 1. Create the DrawTextAnimation widget with custom painter


  - Create a new file `lib/widgets/draw_text_animation.dart`
  - Implement `DrawTextAnimation` StatefulWidget with properties: text, duration, strokeColor, strokeWidth, textStyle, and onFinish callback
  - Implement `_DrawTextAnimationState` with `SingleTickerProviderStateMixin` for animation controller
  - Set up animation controller with configurable duration
  - Create animation with `CurvedAnimation` using `Curves.easeInOut`
  - _Requirements: 1.1, 1.2, 1.3, 3.1, 3.2_

- [x] 1.1 Implement TextStrokePainter custom painter


  - Create `TextStrokePainter` class extending `CustomPainter`
  - Implement text path extraction using `TextPainter` to get text metrics
  - Create stroke paint with configurable color and width
  - Implement progressive path drawing based on animation progress (0.0 to 1.0)
  - Use `PathMetrics` to calculate path segments and draw only the visible portion
  - Override `shouldRepaint` to return true when progress changes
  - _Requirements: 1.1, 1.4, 3.4_



- [ ] 1.2 Add animation lifecycle management
  - Implement `initState` to initialize animation controller
  - Add animation listener to trigger `setState` for repainting
  - Add status listener to detect animation completion and call `onFinish` callback
  - Implement `dispose` to properly clean up animation controller
  - _Requirements: 1.5, 4.2, 4.5_

- [x] 2. Integrate DrawTextAnimation into splash screen


  - Open `lib/screens/splash_screen.dart`
  - Import the new `DrawTextAnimation` widget
  - Remove or comment out existing `_fadeTextAnimation` and `_slideTextAnimation` setup
  - Add new animation interval for text drawing (0.25 to 0.5)
  - Add state variable `_showDrawText` to control when text animation starts
  - _Requirements: 2.1, 2.2, 2.5_

- [x] 2.1 Update animation controller configuration


  - Modify animation intervals to accommodate text stroke animation
  - Ensure logo animation completes before text animation starts (0.0-0.25 for logo)
  - Configure text animation interval (0.25-0.5)
  - Ensure tagline animation starts after text completes (0.5-0.75)
  - Maintain pulse animation timing (0.75-1.0)
  - _Requirements: 2.1, 2.2, 2.3, 2.5_

- [x] 2.2 Replace text widget with DrawTextAnimation


  - Replace the existing `FadeTransition` and `Transform.translate` text widget
  - Add `DrawTextAnimation` widget with app name from `AppConstants.appName`
  - Configure duration to 2 seconds (matching interval 0.25-0.5)
  - Set stroke color to white with appropriate opacity
  - Set stroke width to 3.0
  - Apply existing text style (fontSize: 48, fontWeight: bold, letterSpacing: 2)
  - Add `onFinish` callback to trigger subsequent animations if needed
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 3.4_


- [x] 3. Add error handling and fallback mechanism

  - Wrap DrawTextAnimation in error boundary or try-catch
  - Implement fallback to simple fade-in text if animation fails
  - Add conditional rendering: if animation fails, show static text with fade
  - Log errors for debugging without crashing the app
  - _Requirements: 4.1, 4.3_

- [x] 4. Optimize performance and test


  - Test animation on physical device for smoothness
  - Use Flutter DevTools to monitor frame rate during animation
  - Verify animation maintains 60fps
  - Check memory usage and ensure proper disposal
  - Test on different screen sizes and Android versions
  - Verify complete animation sequence: logo → text stroke → tagline → pulse → navigate
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 5. Fine-tune visual styling


  - Adjust stroke color for optimal contrast against gradient background
  - Fine-tune stroke width if needed (test values between 2.5-4.0)
  - Verify text shadows work well with stroke animation
  - Ensure text positioning matches original layout
  - Test animation timing feels natural (adjust duration if needed)
  - _Requirements: 1.1, 1.4, 3.2, 3.3, 3.4_
