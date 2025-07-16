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
    As a creative UI/UX developer, provide a unique and detailed project specification for:
    
    Project Name: ${request.projectName}
    Project Topic: ${request.topic}
    Platform: ${request.platform}
    Tech Stack: ${request.techStack}
    
    Please provide ONLY the following sections (use exact headings):

    PROJECT DESCRIPTION:
    Write a unique and detailed description of what this project "${request.projectName}" will do and its purpose (2-3 paragraphs). Make sure to use the project name throughout the description.

    PAGES/SCREENS:
    List all the pages/screens needed for ${request.projectName} with a brief purpose for each.

    KEY FEATURES:
    List 5-8 specific and unique features ${request.projectName} will have. Be creative and detailed.

    UI DESIGN:
    - Describe the overall theme and style for ${request.projectName}
    - Suggest a specific color palette (with hex codes)
    - Describe layout patterns and components
    - Mention specific animations or transitions
    - Suggest typography and icon styles

    FOLDER STRUCTURE:
    Provide a detailed folder and file structure specific to this ${request.platform} project using ${request.techStack}. Include appropriate file names that reflect the project name "${request.projectName}".

    Important:
    - Be specific and unique to this exact project
    - No generic responses
    - No placeholder text
    - Include actual color codes
    - Make each section detailed and practical
    - Use the project name "${request.projectName}" throughout the response
    ''';
  }

  String _extractSection(List<String> sections, String sectionName) {
    try {
      // Find the section header first
      int headerIndex = -1;
      for (int i = 0; i < sections.length; i++) {
        if (sections[i].toLowerCase().contains(sectionName.toLowerCase())) {
          headerIndex = i;
          break;
        }
      }

      if (headerIndex == -1 || headerIndex >= sections.length - 1) {
        return ''; // Header not found or it's the last section
      }

      // Collect all content until the next section header
      List<String> contentSections = [];
      int i = headerIndex + 1;
      while (i < sections.length &&
          !sections[i].toLowerCase().contains("project description") &&
          !sections[i].toLowerCase().contains("pages/screens") &&
          !sections[i].toLowerCase().contains("key features") &&
          !sections[i].toLowerCase().contains("ui design") &&
          !sections[i].toLowerCase().contains("folder structure")) {
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

      final projectDesc = _extractSection(sections, "PROJECT DESCRIPTION");
      final pages = _extractSection(sections, "PAGES/SCREENS");
      final features = _extractListSection(sections, "KEY FEATURES");
      final uiDesign = _extractSection(sections, "UI DESIGN");
      final structure = _extractSection(sections, "FOLDER STRUCTURE");

      return PromptResponse(
        summary: projectDesc.isNotEmpty
            ? projectDesc
            : "No project description available",
        features: features.isNotEmpty ? features : ["No features available"],
        uiLayout: uiDesign.isNotEmpty ? uiDesign : "No UI design available",
        techStackExplanation: pages.isNotEmpty
            ? pages
            : "No pages/screens available",
        folderStructure: structure.isNotEmpty
            ? structure
            : "No folder structure available",
        developmentSteps: [], // Empty since we don't want development steps
        aiIntegration: null, // Null since we don't want AI integration
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
