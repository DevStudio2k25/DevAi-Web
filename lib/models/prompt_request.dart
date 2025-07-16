class PromptRequest {
  final String topic;
  final String platform;
  final String techStack;
  final String projectName;
  final DateTime timestamp;

  PromptRequest({
    required this.topic,
    required this.platform,
    required this.techStack,
    required this.projectName,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'platform': platform,
      'techStack': techStack,
      'projectName': projectName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PromptRequest.fromJson(Map<String, dynamic> json) {
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
    
    return PromptRequest(
      topic: json['topic'] as String,
      platform: json['platform'] as String,
      techStack: json['techStack'] as String,
      projectName: json['projectName'] as String,
      timestamp: parseTimestamp(json['timestamp']),
    );
  }
}
