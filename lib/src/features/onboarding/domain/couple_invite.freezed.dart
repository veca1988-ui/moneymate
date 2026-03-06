// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'couple_invite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CoupleInvite _$CoupleInviteFromJson(Map<String, dynamic> json) {
  return _CoupleInvite.fromJson(json);
}

/// @nodoc
mixin _$CoupleInvite {
  String get code => throw _privateConstructorUsedError;
  String get creatorUserId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  bool get used => throw _privateConstructorUsedError;
  String? get coupleId => throw _privateConstructorUsedError;

  /// Serializes this CoupleInvite to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoupleInvite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoupleInviteCopyWith<CoupleInvite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoupleInviteCopyWith<$Res> {
  factory $CoupleInviteCopyWith(
          CoupleInvite value, $Res Function(CoupleInvite) then) =
      _$CoupleInviteCopyWithImpl<$Res, CoupleInvite>;
  @useResult
  $Res call(
      {String code,
      String creatorUserId,
      DateTime createdAt,
      DateTime expiresAt,
      bool used,
      String? coupleId});
}

/// @nodoc
class _$CoupleInviteCopyWithImpl<$Res, $Val extends CoupleInvite>
    implements $CoupleInviteCopyWith<$Res> {
  _$CoupleInviteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoupleInvite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? creatorUserId = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? used = null,
    Object? coupleId = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      creatorUserId: null == creatorUserId
          ? _value.creatorUserId
          : creatorUserId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      used: null == used
          ? _value.used
          : used // ignore: cast_nullable_to_non_nullable
              as bool,
      coupleId: freezed == coupleId
          ? _value.coupleId
          : coupleId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoupleInviteImplCopyWith<$Res>
    implements $CoupleInviteCopyWith<$Res> {
  factory _$$CoupleInviteImplCopyWith(
          _$CoupleInviteImpl value, $Res Function(_$CoupleInviteImpl) then) =
      __$$CoupleInviteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      String creatorUserId,
      DateTime createdAt,
      DateTime expiresAt,
      bool used,
      String? coupleId});
}

/// @nodoc
class __$$CoupleInviteImplCopyWithImpl<$Res>
    extends _$CoupleInviteCopyWithImpl<$Res, _$CoupleInviteImpl>
    implements _$$CoupleInviteImplCopyWith<$Res> {
  __$$CoupleInviteImplCopyWithImpl(
      _$CoupleInviteImpl _value, $Res Function(_$CoupleInviteImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoupleInvite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? creatorUserId = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? used = null,
    Object? coupleId = freezed,
  }) {
    return _then(_$CoupleInviteImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      creatorUserId: null == creatorUserId
          ? _value.creatorUserId
          : creatorUserId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      used: null == used
          ? _value.used
          : used // ignore: cast_nullable_to_non_nullable
              as bool,
      coupleId: freezed == coupleId
          ? _value.coupleId
          : coupleId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoupleInviteImpl implements _CoupleInvite {
  const _$CoupleInviteImpl(
      {required this.code,
      required this.creatorUserId,
      required this.createdAt,
      required this.expiresAt,
      this.used = false,
      this.coupleId});

  factory _$CoupleInviteImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoupleInviteImplFromJson(json);

  @override
  final String code;
  @override
  final String creatorUserId;
  @override
  final DateTime createdAt;
  @override
  final DateTime expiresAt;
  @override
  @JsonKey()
  final bool used;
  @override
  final String? coupleId;

  @override
  String toString() {
    return 'CoupleInvite(code: $code, creatorUserId: $creatorUserId, createdAt: $createdAt, expiresAt: $expiresAt, used: $used, coupleId: $coupleId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoupleInviteImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.creatorUserId, creatorUserId) ||
                other.creatorUserId == creatorUserId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.used, used) || other.used == used) &&
            (identical(other.coupleId, coupleId) ||
                other.coupleId == coupleId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, code, creatorUserId, createdAt, expiresAt, used, coupleId);

  /// Create a copy of CoupleInvite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoupleInviteImplCopyWith<_$CoupleInviteImpl> get copyWith =>
      __$$CoupleInviteImplCopyWithImpl<_$CoupleInviteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoupleInviteImplToJson(
      this,
    );
  }
}

abstract class _CoupleInvite implements CoupleInvite {
  const factory _CoupleInvite(
      {required final String code,
      required final String creatorUserId,
      required final DateTime createdAt,
      required final DateTime expiresAt,
      final bool used,
      final String? coupleId}) = _$CoupleInviteImpl;

  factory _CoupleInvite.fromJson(Map<String, dynamic> json) =
      _$CoupleInviteImpl.fromJson;

  @override
  String get code;
  @override
  String get creatorUserId;
  @override
  DateTime get createdAt;
  @override
  DateTime get expiresAt;
  @override
  bool get used;
  @override
  String? get coupleId;

  /// Create a copy of CoupleInvite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoupleInviteImplCopyWith<_$CoupleInviteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
