// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couple_invite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoupleInviteImpl _$$CoupleInviteImplFromJson(Map<String, dynamic> json) =>
    _$CoupleInviteImpl(
      code: json['code'] as String,
      creatorUserId: json['creatorUserId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      used: json['used'] as bool? ?? false,
      coupleId: json['coupleId'] as String?,
    );

Map<String, dynamic> _$$CoupleInviteImplToJson(_$CoupleInviteImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'creatorUserId': instance.creatorUserId,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'used': instance.used,
      'coupleId': instance.coupleId,
    };
