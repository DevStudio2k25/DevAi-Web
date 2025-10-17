class PromptResponse {
  // Core sections
  final String summary; // Project Overview
  final String techStackExplanation; // Pages/Screens
  final List<String> features; // Key Features
  final String uiLayout; // UI Design System
  final String folderStructure; // Architecture & Folder Structure

  // New enhanced sections
  final String? recommendedPackages; // Recommended Packages
  final String? nonFunctionalRequirements; // Performance, Security, etc.
  final String? testingStrategy; // Testing & CI/CD
  final String? acceptanceCriteria; // MVP Acceptance Criteria
  final String? developmentRoadmap; // Development Roadmap

  // Legacy fields (kept for backward compatibility)
  final List<String> developmentSteps;
  final String? aiIntegration;

  final DateTime timestamp;

  PromptResponse({
    required this.summary,
    required this.features,
    required this.uiLayout,
    required this.techStackExplanation,
    required this.folderStructure,
    this.recommendedPackages,
    this.nonFunctionalRequirements,
    this.testingStrategy,
    this.acceptanceCriteria,
    this.developmentRoadmap,
    this.developmentSteps = const [],
    this.aiIntegration,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'features': features,
      'uiLayout': uiLayout,
      'techStackExplanation': techStackExplanation,
      'folderStructure': folderStructure,
      'recommendedPackages': recommendedPackages,
      'nonFunctionalRequirements': nonFunctionalRequirements,
      'testingStrategy': testingStrategy,
      'acceptanceCriteria': acceptanceCriteria,
      'developmentRoadmap': developmentRoadmap,
      'developmentSteps': developmentSteps,
      'aiIntegration': aiIntegration,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PromptResponse.fromJson(Map<String, dynamic> json) {
    // Handle timestamp which can be String, DateTime, or Firestore Timestamp
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      if (timestamp is String) return DateTime.parse(timestamp);
      if (timestamp is DateTime) return timestamp;

      // Handle Firestore Timestamp
      try {
        return timestamp.toDate();
      } catch (e) {
        return DateTime.now();
      }
    }

    return PromptResponse(
      summary: json['summary'] as String,
      features: List<String>.from(json['features'] as List),
      uiLayout: json['uiLayout'] as String,
      techStackExplanation: json['techStackExplanation'] as String,
      folderStructure: json['folderStructure'] as String,
      recommendedPackages: json['recommendedPackages'] as String?,
      nonFunctionalRequirements: json['nonFunctionalRequirements'] as String?,
      testingStrategy: json['testingStrategy'] as String?,
      acceptanceCriteria: json['acceptanceCriteria'] as String?,
      developmentRoadmap: json['developmentRoadmap'] as String?,
      developmentSteps: json['developmentSteps'] != null
          ? List<String>.from(json['developmentSteps'] as List)
          : [],
      aiIntegration: json['aiIntegration'] as String?,
      timestamp: parseTimestamp(json['timestamp']),
    );
  }
}
