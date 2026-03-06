import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'couple.freezed.dart';
part 'couple.g.dart';

@freezed
class Couple with _$Couple {
  const factory Couple({
    required String id,
    required String user1Id,
    required String user2Id,
    required DateTime createdAt,
    required String subscriptionStatus,
    required DateTime trialStartDate,
    required DateTime trialEndDate,
    String? subscriberUserId,
    DateTime? expiresAt,
  }) = _Couple;

  factory Couple.fromJson(Map<String, dynamic> json) =>
      _$CoupleFromJson(json);

  factory Couple.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return Couple.fromJson({
      'id': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'trialStartDate':
          (data['trialStartDate'] as Timestamp).toDate().toIso8601String(),
      'trialEndDate':
          (data['trialEndDate'] as Timestamp).toDate().toIso8601String(),
      if (data['expiresAt'] != null)
        'expiresAt':
            (data['expiresAt'] as Timestamp).toDate().toIso8601String(),
    });
  }
}
