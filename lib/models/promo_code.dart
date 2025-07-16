import 'package:cloud_firestore/cloud_firestore.dart';

class PromoCode {
  final String id;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final int tokenAmount;
  final List<String> usedByUsers;

  PromoCode({
    required this.id,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    required this.isActive,
    required this.tokenAmount,
    required this.usedByUsers,
  });

  factory PromoCode.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromoCode(
      id: doc.id,
      code: data['code'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? false,
      tokenAmount: data['tokenAmount'] ?? 0,
      usedByUsers: List<String>.from(data['usedByUsers'] ?? []),
    );
  }

  bool isExpired() {
    return DateTime.now().isAfter(expiresAt);
  }

  bool isUsedByUser(String userId) {
    return usedByUsers.contains(userId);
  }
}
