import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/prompt_request.dart';
import '../models/prompt_response.dart';
import 'storage_service.dart';

class GeminiService {
  final StorageService _storageService;
  GenerativeModel? _model;

  GeminiService(this._storageService);

  Future<void> initialize({String? apiKey}) async {
    try {
      final key = apiKey ?? await _storageService.getApiKey();
      if (key != null && key.isNotEmpty) {
        _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: key);
      }
    } catch (e) {
      // Handle initialization error silently
      _model = null;
    }
  }

  // Method to verify if the API key is valid
  Future<bool> verifyApiKey(String apiKey) async {
    try {
      // Create a temporary model with the provided API key
      final tempModel = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
      );

      // Make a simple test request with a prompt that asks the model to identify itself as DevAi
      final content = [
        Content.text(
          'Please respond with exactly this phrase: "I am DevAi made by DevStudio team"',
        ),
      ];
      final response = await tempModel.generateContent(content);

      // If we get a response containing our custom phrase, the API key is valid
      final responseText = response.text ?? '';
      return responseText.contains('DevAi') &&
          responseText.contains('DevStudio');
    } catch (e) {
      // If there's an error, the API key is invalid
      return false;
    }
  }

  String _buildPrompt(PromptRequest request) {
    return '''
    As an expert software architect and full-stack developer, generate a comprehensive, production-ready project specification for:
    
    Project Name: ${request.projectName}
    Project Topic: ${request.topic}
    Platform: ${request.platform}
    Tech Stack: ${request.techStack}
    
    Provide a COMPLETE, STRUCTURED specification with these EXACT sections:

    1. PROJECT OVERVIEW:
    - Write 2-3 detailed paragraphs about "${request.projectName}"
    - Include target audience, core problem it solves, and unique value proposition
    - Mention MVP scope vs future enhancements

    2. PAGES/SCREENS:
    - List ALL screens/pages needed with detailed purpose
    - Include navigation flow between screens
    - Specify which screens are MVP vs Phase 2

    3. KEY FEATURES:
    - List 8-12 features categorized as:
      * Core Features (MVP)
      * Advanced Features (Phase 2)
      * AI-Powered Features (if applicable)
    - Each feature should have 2-3 lines of detail

    4. UI DESIGN SYSTEM:
    - Theme & Style (modern, minimalist, etc.)
    - Color Palette with hex codes:
      * Primary, Secondary, Accent colors
      * Success, Warning, Error, Info colors
      * Background, Surface, Text colors (light & dark mode)
    - Typography:
      * Heading fonts with sizes
      * Body text fonts with sizes
      * Monospace fonts for code
    - Icons: Specify icon library
    - Animations: List key animations and transitions
    - Layout Patterns: Navigation style, card designs, etc.

    5. ARCHITECTURE & FOLDER STRUCTURE:
    - Recommend architecture pattern (Clean Architecture, Feature-first, MVVM, etc.)
    - Suggest state management approach
    - Provide COMPLETE folder structure with:
      * All directories and subdirectories
      * Key files with actual names
      * Organized by feature/module
      * Include test folders

    6. RECOMMENDED PACKAGES:
    For ${request.techStack} on ${request.platform}, suggest packages for:
    - State Management (primary + alternative)
    - Routing/Navigation (primary + alternative)
    - Local Storage (primary + alternative)
    - HTTP/API Client (primary + alternative)
    - Authentication (if needed)
    - UI Components/Utilities
    - Testing frameworks
    Include 1-2 line reasoning for each

    7. NON-FUNCTIONAL REQUIREMENTS:
    - Performance: Target metrics (load time, frame rate, etc.)
    - Offline Mode: Strategy for offline functionality
    - Security: Data encryption, token handling, secure storage
    - Accessibility: WCAG compliance, screen reader support
    - Internationalization: Multi-language support approach
    - Platform-Specific: Min SDK versions, browser support, etc.

    8. TESTING STRATEGY:
    - List 8-10 test cases covering:
      * Unit tests (business logic)
      * Widget/Component tests (UI)
      * Integration tests (user flows)
      * E2E tests (critical paths)
    - Suggest test coverage goals (e.g., 80%+)
    - Recommend CI/CD approach (GitHub Actions, etc.)

    9. ACCEPTANCE CRITERIA (MVP):
    - List 10-15 clear, testable criteria for MVP completion
    - Each should be specific and measurable
    - Prioritize by must-have vs nice-to-have

    10. DEVELOPMENT ROADMAP:
    - Phase 1 (MVP): 2-4 weeks
    - Phase 2 (Advanced Features): 4-6 weeks
    - Phase 3 (Polish & Scale): 2-3 weeks
    - List key milestones for each phase

    IMPORTANT RULES:
    - Be SPECIFIC to "${request.projectName}" - no generic responses
    - Include ACTUAL values (hex codes, package names, versions)
    - Make it DEVELOPER-READY - someone should be able to start coding immediately
    - Use the project name "${request.projectName}" throughout
    - Provide PRACTICAL, PRODUCTION-READY recommendations
    - Consider real-world constraints (performance, security, scalability)
    ''';
  }

  String _extractSection(List<String> sections, String sectionName) {
    try {
      // Find the section header first (supports numbered sections like "1. PROJECT OVERVIEW")
      int headerIndex = -1;
      for (int i = 0; i < sections.length; i++) {
        final section = sections[i].toLowerCase();
        // Remove numbers and special characters for matching
        final cleanSection = section.replaceAll(RegExp(r'^\d+\.\s*'), '');
        if (cleanSection.contains(sectionName.toLowerCase())) {
          headerIndex = i;
          break;
        }
      }

      if (headerIndex == -1 || headerIndex >= sections.length - 1) {
        return ''; // Header not found or it's the last section
      }

      // Collect all content until the next numbered section header
      List<String> contentSections = [];
      int i = headerIndex + 1;
      while (i < sections.length) {
        final section = sections[i].trim();
        // Check if this is a new numbered section (e.g., "2. PAGES/SCREENS")
        if (RegExp(r'^\d+\.\s+[A-Z]').hasMatch(section)) {
          break;
        }
        contentSections.add(sections[i]);
        i++;
      }

      return contentSections.join("\n\n").trim();
    } catch (e) {
      // Handle extraction error silently
      return '';
    }
  }

  List<String> _extractListSection(List<String> sections, String sectionName) {
    try {
      final content = _extractSection(sections, sectionName);
      if (content.isEmpty) return [];

      // Split by numbered or bulleted items
      final items = content.split(RegExp(r'\d+\.\s+|\*\s+|-\s+|•\s+'));

      return items
          .where((item) => item.trim().isNotEmpty)
          .map((item) => item.trim())
          .toList();
    } catch (e) {
      // Handle extraction error silently
      return [];
    }
  }

  Future<PromptResponse> generatePrompt(PromptRequest request) async {
    if (_model == null) {
      throw Exception('Gemini API not initialized. Please set API key first.');
    }

    final prompt = _buildPrompt(request);
    final content = [Content.text(prompt)];

    try {
      final response = await _model!.generateContent(content);
      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      // Split response into sections by double newlines
      final sections = text.split(RegExp(r'\n{2,}'));

      // Extract all sections
      final projectOverview = _extractSection(sections, "PROJECT OVERVIEW");
      final pagesScreens = _extractSection(sections, "PAGES/SCREENS");
      final features = _extractListSection(sections, "KEY FEATURES");
      final uiDesign = _extractSection(sections, "UI DESIGN SYSTEM");
      final architecture = _extractSection(sections, "ARCHITECTURE");
      final packages = _extractSection(sections, "RECOMMENDED PACKAGES");
      final nonFunctional = _extractSection(
        sections,
        "NON-FUNCTIONAL REQUIREMENTS",
      );
      final testing = _extractSection(sections, "TESTING STRATEGY");
      final acceptance = _extractSection(sections, "ACCEPTANCE CRITERIA");
      final roadmap = _extractSection(sections, "DEVELOPMENT ROADMAP");

      return PromptResponse(
        summary: projectOverview.isNotEmpty
            ? projectOverview
            : "No project overview available",
        features: features.isNotEmpty ? features : ["No features available"],
        uiLayout: uiDesign.isNotEmpty ? uiDesign : "No UI design available",
        techStackExplanation: pagesScreens.isNotEmpty
            ? pagesScreens
            : "No pages/screens available",
        folderStructure: architecture.isNotEmpty
            ? architecture
            : "No architecture details available",
        recommendedPackages: packages.isNotEmpty ? packages : null,
        nonFunctionalRequirements: nonFunctional.isNotEmpty
            ? nonFunctional
            : null,
        testingStrategy: testing.isNotEmpty ? testing : null,
        acceptanceCriteria: acceptance.isNotEmpty ? acceptance : null,
        developmentRoadmap: roadmap.isNotEmpty ? roadmap : null,
        developmentSteps: [],
        aiIntegration: null,
      );
    } catch (e) {
      // More descriptive error message
      if (e.toString().contains('403')) {
        throw Exception(
          'API key unauthorized. Please check your Gemini API key.',
        );
      } else if (e.toString().contains('429')) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else if (e.toString().contains('timeout')) {
        throw Exception(
          'Connection timed out. Please check your internet connection.',
        );
      } else {
        throw Exception('Failed to generate prompt: ${e.toString()}');
      }
    }
  }
}
