// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'couple.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Couple _$CoupleFromJson(Map<String, dynamic> json) {
  return _Couple.fromJson(json);
}

/// @nodoc
mixin _$Couple {
  String get id => throw _privateConstructorUsedError;
  String get user1Id => throw _privateConstructorUsedError;
  String get user2Id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get subscriptionStatus => throw _privateConstructorUsedError;
  DateTime get trialStartDate => throw _privateConstructorUsedError;
  DateTime get trialEndDate => throw _privateConstructorUsedError;
  String? get subscriberUserId => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this Couple to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Couple
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoupleCopyWith<Couple> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoupleCopyWith<$Res> {
  factory $CoupleCopyWith(Couple value, $Res Function(Couple) then) =
      _$CoupleCopyWithImpl<$Res, Couple>;
  @useResult
  $Res call(
      {String id,
      String user1Id,
      String user2Id,
      DateTime createdAt,
      String subscriptionStatus,
      DateTime trialStartDate,
      DateTime trialEndDate,
      String? subscriberUserId,
      DateTime? expiresAt});
}

/// @nodoc
class _$CoupleCopyWithImpl<$Res, $Val extends Couple>
    implements $CoupleCopyWith<$Res> {
  _$CoupleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Couple
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user1Id = null,
    Object? user2Id = null,
    Object? createdAt = null,
    Object? subscriptionStatus = null,
    Object? trialStartDate = null,
    Object? trialEndDate = null,
    Object? subscriberUserId = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user1Id: null == user1Id
          ? _value.user1Id
          : user1Id // ignore: cast_nullable_to_non_nullable
              as String,
      user2Id: null == user2Id
          ? _value.user2Id
          : user2Id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      subscriptionStatus: null == subscriptionStatus
          ? _value.subscriptionStatus
          : subscriptionStatus // ignore: cast_nullable_to_non_nullable
              as String,
      trialStartDate: null == trialStartDate
          ? _value.trialStartDate
          : trialStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      trialEndDate: null == trialEndDate
          ? _value.trialEndDate
          : trialEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      subscriberUserId: freezed == subscriberUserId
          ? _value.subscriberUserId
          : subscriberUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoupleImplCopyWith<$Res> implements $CoupleCopyWith<$Res> {
  factory _$$CoupleImplCopyWith(
          _$CoupleImpl value, $Res Function(_$CoupleImpl) then) =
      __$$CoupleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String user1Id,
      String user2Id,
      DateTime createdAt,
      String subscriptionStatus,
      DateTime trialStartDate,
      DateTime trialEndDate,
      String? subscriberUserId,
      DateTime? expiresAt});
}

/// @nodoc
class __$$CoupleImplCopyWithImpl<$Res>
    extends _$CoupleCopyWithImpl<$Res, _$CoupleImpl>
    implements _$$CoupleImplCopyWith<$Res> {
  __$$CoupleImplCopyWithImpl(
      _$CoupleImpl _value, $Res Function(_$CoupleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Couple
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user1Id = null,
    Object? user2Id = null,
    Object? createdAt = null,
    Object? subscriptionStatus = null,
    Object? trialStartDate = null,
    Object? trialEndDate = null,
    Object? subscriberUserId = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_$CoupleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user1Id: null == user1Id
          ? _value.user1Id
          : user1Id // ignore: cast_nullable_to_non_nullable
              as String,
      user2Id: null == user2Id
          ? _value.user2Id
          : user2Id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      subscriptionStatus: null == subscriptionStatus
          ? _value.subscriptionStatus
          : subscriptionStatus // ignore: cast_nullable_to_non_nullable
              as String,
      trialStartDate: null == trialStartDate
          ? _value.trialStartDate
          : trialStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      trialEndDate: null == trialEndDate
          ? _value.trialEndDate
          : trialEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      subscriberUserId: freezed == subscriberUserId
          ? _value.subscriberUserId
          : subscriberUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoupleImpl implements _Couple {
  const _$CoupleImpl(
      {required this.id,
      required this.user1Id,
      required this.user2Id,
      required this.createdAt,
      required this.subscriptionStatus,
      required this.trialStartDate,
      required this.trialEndDate,
      this.subscriberUserId,
      this.expiresAt});

  factory _$CoupleImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoupleImplFromJson(json);

  @override
  final String id;
  @override
  final String user1Id;
  @override
  final String user2Id;
  @override
  final DateTime createdAt;
  @override
  final String subscriptionStatus;
  @override
  final DateTime trialStartDate;
  @override
  final DateTime trialEndDate;
  @override
  final String? subscriberUserId;
  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'Couple(id: $id, user1Id: $user1Id, user2Id: $user2Id, createdAt: $createdAt, subscriptionStatus: $subscriptionStatus, trialStartDate: $trialStartDate, trialEndDate: $trialEndDate, subscriberUserId: $subscriberUserId, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoupleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user1Id, user1Id) || other.user1Id == user1Id) &&
            (identical(other.user2Id, user2Id) || other.user2Id == user2Id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.subscriptionStatus, subscriptionStatus) ||
                other.subscriptionStatus == subscriptionStatus) &&
            (identical(other.trialStartDate, trialStartDate) ||
                other.trialStartDate == trialStartDate) &&
            (identical(other.trialEndDate, trialEndDate) ||
                other.trialEndDate == trialEndDate) &&
            (identical(other.subscriberUserId, subscriberUserId) ||
                other.subscriberUserId == subscriberUserId) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      user1Id,
      user2Id,
      createdAt,
      subscriptionStatus,
      trialStartDate,
      trialEndDate,
      subscriberUserId,
      expiresAt);

  /// Create a copy of Couple
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoupleImplCopyWith<_$CoupleImpl> get copyWith =>
      __$$CoupleImplCopyWithImpl<_$CoupleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoupleImplToJson(
      this,
    );
  }
}

abstract class _Couple implements Couple {
  const factory _Couple(
      {required final String id,
      required final String user1Id,
      required final String user2Id,
      required final DateTime createdAt,
      required final String subscriptionStatus,
      required final DateTime trialStartDate,
      required final DateTime trialEndDate,
      final String? subscriberUserId,
      final DateTime? expiresAt}) = _$CoupleImpl;

  factory _Couple.fromJson(Map<String, dynamic> json) = _$CoupleImpl.fromJson;

  @override
  String get id;
  @override
  String get user1Id;
  @override
  String get user2Id;
  @override
  DateTime get createdAt;
  @override
  String get subscriptionStatus;
  @override
  DateTime get trialStartDate;
  @override
  DateTime get trialEndDate;
  @override
  String? get subscriberUserId;
  @override
  DateTime? get expiresAt;

  /// Create a copy of Couple
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoupleImplCopyWith<_$CoupleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
