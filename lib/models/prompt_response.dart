class PromptResponse {
  final String summary;
  final List<String> features;
  final String uiLayout;
  final String techStackExplanation;
  final String folderStructure;
  final List<String> developmentSteps;
  final String? aiIntegration;
  final DateTime timestamp;

  PromptResponse({
    required this.summary,
    required this.features,
    required this.uiLayout,
    required this.techStackExplanation,
    required this.folderStructure,
    required this.developmentSteps,
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
        // For Firestore Timestamp, use toDate() method
        return timestamp.toDate();
      } catch (e) {
        // Fallback to current time if parsing fails
        return DateTime.now();
      }
    }

    return PromptResponse(
      summary: json['summary'] as String,
      features: List<String>.from(json['features'] as List),
      uiLayout: json['uiLayout'] as String,
      techStackExplanation: json['techStackExplanation'] as String,
      folderStructure: json['folderStructure'] as String,
      developmentSteps: List<String>.from(json['developmentSteps'] as List),
      aiIntegration: json['aiIntegration'] as String?,
      timestamp: parseTimestamp(json['timestamp']),
    );
  }
}
