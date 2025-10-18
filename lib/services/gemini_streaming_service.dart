// ignore_for_file: avoid_print

import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/prompt_request.dart';
import 'storage_service.dart';

class GeminiStreamingService {
  final StorageService _storageService;
  GenerativeModel? _model;

  GeminiStreamingService(this._storageService);

  Future<void> initialize({String? apiKey}) async {
    try {
      final key = apiKey ?? await _storageService.getApiKey();
      if (key != null && key.isNotEmpty) {
        _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: key);
      }
    } catch (e) {
      _model = null;
    }
  }

  // Get total phase count for a request
  int getTotalPhases(PromptRequest request) {
    return _getRelevantPhases(request).length;
  }

  // Get selected phase numbers for a request
  List<int> getSelectedPhases(PromptRequest request) {
    return _getRelevantPhases(request);
  }

  // Manual retry for a specific phase with cooldown
  Future<String> retryPhase(PromptRequest request, int phaseNumber) async {
    if (_model == null) {
      throw Exception('Gemini API not initialized');
    }

    print('🔄 [RETRY] Starting manual retry for phase $phaseNumber');
    print('⏳ [RETRY] Waiting 20 seconds to avoid rate limiting...');

    // 20 second cooldown to avoid rate limiting
    await Future.delayed(const Duration(seconds: 20));

    print('✅ [RETRY] Cooldown complete, generating phase $phaseNumber...');

    final prompt = _buildPhasePrompt(request, phaseNumber);
    final content = [Content.text(prompt)];

    try {
      final response = await _model!.generateContent(content);
      final text = response.text;

      if (text != null && text.trim().isNotEmpty) {
        print(
          '✅ [RETRY] Phase $phaseNumber regenerated successfully (${text.length} chars)',
        );
        return text.trim();
      } else {
        throw Exception('Empty response from API');
      }
    } catch (e) {
      print('❌ [RETRY] Failed to regenerate phase $phaseNumber: $e');
      throw Exception('Failed to regenerate: $e');
    }
  }

  // Get phase title for error messages
  String _getPhaseTitle(int phase) {
    const titles = {
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
    return titles[phase] ?? 'Section $phase';
  }

  // Smart phase selection based on project complexity
  List<int> _getRelevantPhases(PromptRequest request) {
    final platform = request.platform.toLowerCase();
    final techStack = request.techStack.toLowerCase();

    // Simple web projects (HTML/CSS/JS, basic sites)
    if (_isSimpleWebProject(platform, techStack)) {
      return [
        1,
        2,
        3,
        4,
        5,
        10,
      ]; // 6 phases: Overview, Pages, Features, Design, Structure, Roadmap
    }

    // Medium complexity (React, Vue, Angular, simple mobile)
    if (_isMediumComplexity(platform, techStack)) {
      return [1, 2, 3, 4, 5, 6, 9, 10]; // 8 phases: Skip NFR and Testing
    }

    // High complexity (Full-stack, Native mobile, Complex frameworks)
    return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]; // All 10 phases
  }

  bool _isSimpleWebProject(String platform, String techStack) {
    // Simple HTML/CSS/JS projects
    if (platform.contains('web') &&
        (techStack.contains('html') ||
            techStack.contains('css') ||
            techStack.contains('javascript') &&
                !techStack.contains('react') &&
                !techStack.contains('vue') &&
                !techStack.contains('angular'))) {
      return true;
    }
    return false;
  }

  bool _isMediumComplexity(String platform, String techStack) {
    // React, Vue, Angular, Svelte, Next.js
    final mediumFrameworks = ['react', 'vue', 'angular', 'svelte', 'next'];

    // Simple mobile apps (basic Flutter/React Native)
    final simpleMobile = ['flutter', 'react native'];

    for (var framework in mediumFrameworks) {
      if (techStack.contains(framework)) return true;
    }

    if (platform.contains('app')) {
      for (var tech in simpleMobile) {
        if (techStack.contains(tech)) return true;
      }
    }

    return false;
  }

  // Phase-wise prompts - CONCISE & PROJECT-SPECIFIC
  String _buildPhasePrompt(PromptRequest request, int phase) {
    final projectName = request.projectName;
    final topic = request.topic;
    final platform = request.platform;
    final techStack = request.techStack;
    final isSimple = _isSimpleWebProject(
      platform.toLowerCase(),
      techStack.toLowerCase(),
    );

    switch (phase) {
      case 1: // Project Overview
        return '''
Generate CONCISE PROJECT OVERVIEW for: $projectName ($platform - $techStack)
Topic: $topic

${isSimple ? 'Keep it brief (2-3 paragraphs max)' : 'Provide 2-3 detailed paragraphs'} covering:
- What it does & target audience
- Core problem solved
- ${isSimple ? 'Key features' : 'Unique value proposition & MVP scope'}

Start with "# 1. Project Overview" heading.
''';

      case 2: // Pages/Screens
        return '''
Generate ${isSimple ? 'ESSENTIAL' : 'COMPLETE'} PAGES/SCREENS for: $projectName

List ${isSimple ? '4-6 main' : '8-12'} screens/pages:
- Name & purpose (1 line each)
- ${isSimple ? 'Basic navigation flow' : 'Navigation flow & MVP vs Phase 2'}

Start with "# 2. Pages/Screens" heading.
''';

      case 3: // Key Features
        return '''
Generate ${isSimple ? 'CORE' : 'COMPREHENSIVE'} FEATURES for: $projectName

List ${isSimple ? '5-8' : '8-12'} features:
${isSimple ? '- Focus on essential functionality only' : '- Categorize as Core (MVP) & Advanced (Phase 2)'}
- Each feature: 1-2 lines max

Start with "# 3. Key Features" heading.
''';

      case 4: // UI Design System
        return '''
Generate ${isSimple ? 'SIMPLE' : 'COMPLETE'} UI DESIGN SYSTEM for: $projectName

Include:
- Color Palette with hex codes:
  * Primary: #XXXXXX
  * Secondary: #XXXXXX
  * ${isSimple ? 'Background: #XXXXXX' : 'Success: #XXXXXX, Warning: #XXXXXX, Error: #XXXXXX'}
  * ${isSimple ? 'Text: #XXXXXX' : 'Background: #XXXXXX, Surface: #XXXXXX, Text: #XXXXXX'}
- Typography: ${isSimple ? 'Font family only' : 'Heading, Body, Monospace fonts'}
${isSimple ? '' : '- Icons library\n- Key animations\n- Layout patterns'}

Start with "# 4. UI Design System" heading.
''';

      case 5: // Architecture & Folder Structure
        return '''
Generate ${isSimple ? 'BASIC' : 'COMPLETE'} ARCHITECTURE for: $projectName ($techStack)

Include:
- ${isSimple ? 'Simple folder structure (5-8 main folders)' : 'Architecture pattern & state management'}
- ${isSimple ? 'Essential files only' : 'Complete folder structure organized by feature'}
${isSimple ? '' : '- Test folders'}

Start with "# 5. Architecture & Folder Structure" heading.
''';

      case 6: // Recommended Packages
        return '''
Generate ESSENTIAL PACKAGES for: $projectName ($techStack)

List 5-8 key packages:
- State Management (1 recommendation)
- Routing (if needed)
- HTTP/API Client
- ${platform.toLowerCase().contains('app') ? 'Local Storage' : 'Form handling'}
- UI utilities

Keep it concise - name + 1 line purpose only.
Start with "# 6. Recommended Packages" heading.
''';

      case 7: // Non-Functional Requirements
        return '''
Generate ONLY the NON-FUNCTIONAL REQUIREMENTS section for: $projectName

Include:
- Performance metrics
- Offline mode strategy
- Security considerations
- Accessibility (WCAG compliance)
- Internationalization approach
- Platform-specific requirements

Start with "# 7. Non-Functional Requirements" heading.
''';

      case 8: // Testing Strategy
        return '''
Generate ONLY the TESTING STRATEGY section for: $projectName

Include:
- 8-10 test cases (Unit, Widget, Integration, E2E)
- Test coverage goals
- CI/CD approach

Start with "# 8. Testing Strategy" heading.
''';

      case 9: // Acceptance Criteria
        return '''
Generate ONLY the ACCEPTANCE CRITERIA (MVP) section for: $projectName

List 10-15 clear, testable criteria for MVP completion.
Each should be specific and measurable.

Start with "# 9. Acceptance Criteria (MVP)" heading.
''';

      case 10: // Development Roadmap
        return '''
Generate ONLY the DEVELOPMENT ROADMAP section for: $projectName

Include:
- Phase 1 (MVP): 2-4 weeks with milestones
- Phase 2 (Advanced Features): 4-6 weeks with milestones
- Phase 3 (Polish & Scale): 2-3 weeks with milestones

Start with "# 10. Development Roadmap" heading.
''';

      default:
        return '';
    }
  }

  Stream<String> generatePromptStreaming(PromptRequest request) async* {
    if (_model == null) {
      throw Exception('Gemini API not initialized');
    }

    // Get relevant phases based on project complexity
    final relevantPhases = _getRelevantPhases(request);
    final totalPhases = relevantPhases.length;

    print('🚀 [STREAMING] Starting generation for: ${request.projectName}');
    print('� [STRERAMING] Total phases: $totalPhases (Smart selection)');
    print('📋 [STREAMING] Selected phases: $relevantPhases');

    // Generate only relevant phases
    for (int i = 0; i < relevantPhases.length; i++) {
      final phase = relevantPhases[i];
      final displayPhase = i + 1; // Display as 1, 2, 3... for user

      print(
        '🔄 [STREAMING] Generating Phase $displayPhase/$totalPhases (Original: Phase $phase)',
      );

      final prompt = _buildPhasePrompt(request, phase);
      final content = [Content.text(prompt)];

      // Retry logic for failed phases
      int retryCount = 0;
      const maxRetries = 2;
      bool success = false;
      String? generatedText;

      while (!success && retryCount <= maxRetries) {
        try {
          if (retryCount > 0) {
            print(
              '🔄 [STREAMING] Retry attempt $retryCount for Phase $displayPhase',
            );
            await Future.delayed(
              Duration(seconds: retryCount * 2),
            ); // Exponential backoff
          }

          final response = await _model!.generateContent(content);
          final text = response.text;

          if (text != null && text.trim().isNotEmpty) {
            generatedText = text;
            success = true;
            print(
              '✅ [STREAMING] Phase $displayPhase/$totalPhases complete (${text.length} chars)${retryCount > 0 ? ' [Retry $retryCount]' : ''}',
            );
          } else {
            print('⚠️ [STREAMING] Phase $phase returned empty');
            retryCount++;
          }
        } catch (e) {
          print(
            '❌ [STREAMING] Phase $phase error (attempt ${retryCount + 1}): $e',
          );
          retryCount++;

          if (retryCount > maxRetries) {
            // Final failure - provide helpful error message
            generatedText =
                '''
# ${_getPhaseTitle(phase)}

⚠️ **Generation Failed**

This section could not be generated due to:
- API rate limiting or overload
- Network connectivity issues
- Model timeout

**What you can do:**
1. Try regenerating this project
2. Simplify your project description
3. Wait a few minutes and try again

---
''';
          }
        }
      }

      if (generatedText != null) {
        yield '${generatedText.trim()}\n\n';
      }

      // Small delay between phases to avoid rate limiting (except after last phase)
      if (phase < 10) {
        print('⏳ [STREAMING] Waiting 500ms before next phase...');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    print('🎉 [STREAMING] All 10 phases complete! Stream ending.');
    print('🛑 [STREAMING] Stream closed - no more data will be sent');
    // Stream automatically closes after this function ends
  }
}
