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

  // Phase-wise prompts
  String _buildPhasePrompt(PromptRequest request, int phase) {
    final projectName = request.projectName;
    final topic = request.topic;
    final platform = request.platform;
    final techStack = request.techStack;

    switch (phase) {
      case 1: // Project Overview
        return '''
Generate ONLY the PROJECT OVERVIEW section for:
Project: $projectName
Topic: $topic
Platform: $platform
Tech Stack: $techStack

Provide 2-3 detailed paragraphs covering:
- What the project does
- Target audience
- Core problem it solves
- Unique value proposition
- MVP scope vs future enhancements

Start with "# 1. Project Overview" heading.
''';

      case 2: // Pages/Screens
        return '''
Generate ONLY the PAGES/SCREENS section for: $projectName

List ALL screens/pages needed with:
- Detailed purpose for each
- Navigation flow between screens
- Which screens are MVP vs Phase 2

Start with "# 2. Pages/Screens" heading.
''';

      case 3: // Key Features
        return '''
Generate ONLY the KEY FEATURES section for: $projectName

List 8-12 features categorized as:
- Core Features (MVP)
- Advanced Features (Phase 2)
- AI-Powered Features (if applicable)

Each feature should have 2-3 lines of detail.
Start with "# 3. Key Features" heading.
''';

      case 4: // UI Design System
        return '''
Generate ONLY the UI DESIGN SYSTEM section for: $projectName

Include:
- Theme & Style
- Color Palette with hex codes (Primary, Secondary, Success, Warning, Error, Background, Surface, Text)
- Typography (Heading fonts, Body fonts, Monospace)
- Icons (library specification)
- Animations (key animations and transitions)
- Layout Patterns (navigation, cards, etc.)

Start with "# 4. UI Design System" heading.
''';

      case 5: // Architecture & Folder Structure
        return '''
Generate ONLY the ARCHITECTURE & FOLDER STRUCTURE section for: $projectName
Platform: $platform
Tech Stack: $techStack

Include:
- Architecture pattern recommendation
- State management approach
- COMPLETE folder structure with all directories and files
- Organized by feature/module
- Include test folders

Start with "# 5. Architecture & Folder Structure" heading.
''';

      case 6: // Recommended Packages
        return '''
Generate ONLY the RECOMMENDED PACKAGES section for: $projectName
Tech Stack: $techStack
Platform: $platform

Suggest packages for:
- State Management (primary + alternative with reasoning)
- Routing/Navigation (primary + alternative)
- Local Storage (primary + alternative)
- HTTP/API Client (primary + alternative)
- Authentication
- UI Components/Utilities
- Testing frameworks

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

    print('🚀 [STREAMING] Starting generation for: ${request.projectName}');
    print('🔢 [STREAMING] Total phases: 10');

    // Generate each phase sequentially - EXACTLY 10 phases, no more
    for (int phase = 1; phase <= 10; phase++) {
      print('🔄 [STREAMING] Generating Phase $phase/10');

      final prompt = _buildPhasePrompt(request, phase);
      final content = [Content.text(prompt)];

      try {
        final response = await _model!.generateContent(content);
        final text = response.text;

        if (text != null && text.trim().isNotEmpty) {
          print('✅ [STREAMING] Phase $phase complete (${text.length} chars)');
          yield '${text.trim()}\n\n';
        } else {
          print('⚠️ [STREAMING] Phase $phase returned empty');
          yield '# Section $phase\n\nNo content generated.\n\n';
        }
      } catch (e) {
        print('❌ [STREAMING] Phase $phase error: $e');
        yield '# Error in Phase $phase\n\nFailed to generate this section.\n\n';
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
