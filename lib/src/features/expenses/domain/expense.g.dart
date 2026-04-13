// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      userId: json['userId'] as String,
      visibility: json['visibility'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'category': instance.category,
      'date': instance.date.toIso8601String(),
      'userId': instance.userId,
      'visibility': instance.visibility,
      'createdAt': instance.createdAt.toIso8601String(),
      'note': instance.note,
      'userName': instance.userName,
    };
