import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'couple_invite.freezed.dart';
part 'couple_invite.g.dart';

@freezed
class CoupleInvite with _$CoupleInvite {
  const factory CoupleInvite({
    required String code,
    required String creatorUserId,
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default(false) bool used,
    String? coupleId,
  }) = _CoupleInvite;

  factory CoupleInvite.fromJson(Map<String, dynamic> json) =>
      _$CoupleInviteFromJson(json);

  factory CoupleInvite.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return CoupleInvite.fromJson({
      'code': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'expiresAt':
          (data['expiresAt'] as Timestamp).toDate().toIso8601String(),
    });
  }
}
