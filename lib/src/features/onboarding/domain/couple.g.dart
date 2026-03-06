// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couple.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoupleImpl _$$CoupleImplFromJson(Map<String, dynamic> json) => _$CoupleImpl(
      id: json['id'] as String,
      user1Id: json['user1Id'] as String,
      user2Id: json['user2Id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      subscriptionStatus: json['subscriptionStatus'] as String,
      trialStartDate: DateTime.parse(json['trialStartDate'] as String),
      trialEndDate: DateTime.parse(json['trialEndDate'] as String),
      subscriberUserId: json['subscriberUserId'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$CoupleImplToJson(_$CoupleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user1Id': instance.user1Id,
      'user2Id': instance.user2Id,
      'createdAt': instance.createdAt.toIso8601String(),
      'subscriptionStatus': instance.subscriptionStatus,
      'trialStartDate': instance.trialStartDate.toIso8601String(),
      'trialEndDate': instance.trialEndDate.toIso8601String(),
      'subscriberUserId': instance.subscriberUserId,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };
