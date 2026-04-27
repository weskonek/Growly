// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Badge _$BadgeFromJson(Map<String, dynamic> json) {
  return _Badge.fromJson(json);
}

/// @nodoc
mixin _$Badge {
  String get id => throw _privateConstructorUsedError;
  String get childId => throw _privateConstructorUsedError;
  BadgeType get type => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  DateTime get earnedAt => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this Badge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BadgeCopyWith<Badge> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeCopyWith<$Res> {
  factory $BadgeCopyWith(Badge value, $Res Function(Badge) then) =
      _$BadgeCopyWithImpl<$Res, Badge>;
  @useResult
  $Res call(
      {String id,
      String childId,
      BadgeType type,
      String name,
      String description,
      String emoji,
      DateTime earnedAt,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$BadgeCopyWithImpl<$Res, $Val extends Badge>
    implements $BadgeCopyWith<$Res> {
  _$BadgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? type = null,
    Object? name = null,
    Object? description = null,
    Object? emoji = null,
    Object? earnedAt = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as BadgeType,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      earnedAt: null == earnedAt
          ? _value.earnedAt
          : earnedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BadgeImplCopyWith<$Res> implements $BadgeCopyWith<$Res> {
  factory _$$BadgeImplCopyWith(
          _$BadgeImpl value, $Res Function(_$BadgeImpl) then) =
      __$$BadgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String childId,
      BadgeType type,
      String name,
      String description,
      String emoji,
      DateTime earnedAt,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$BadgeImplCopyWithImpl<$Res>
    extends _$BadgeCopyWithImpl<$Res, _$BadgeImpl>
    implements _$$BadgeImplCopyWith<$Res> {
  __$$BadgeImplCopyWithImpl(
      _$BadgeImpl _value, $Res Function(_$BadgeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? type = null,
    Object? name = null,
    Object? description = null,
    Object? emoji = null,
    Object? earnedAt = null,
    Object? metadata = null,
  }) {
    return _then(_$BadgeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as BadgeType,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      earnedAt: null == earnedAt
          ? _value.earnedAt
          : earnedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BadgeImpl implements _Badge {
  const _$BadgeImpl(
      {required this.id,
      required this.childId,
      required this.type,
      required this.name,
      required this.description,
      required this.emoji,
      required this.earnedAt,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$BadgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeImplFromJson(json);

  @override
  final String id;
  @override
  final String childId;
  @override
  final BadgeType type;
  @override
  final String name;
  @override
  final String description;
  @override
  final String emoji;
  @override
  final DateTime earnedAt;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'Badge(id: $id, childId: $childId, type: $type, name: $name, description: $description, emoji: $emoji, earnedAt: $earnedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.earnedAt, earnedAt) ||
                other.earnedAt == earnedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      childId,
      type,
      name,
      description,
      emoji,
      earnedAt,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      __$$BadgeImplCopyWithImpl<_$BadgeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeImplToJson(
      this,
    );
  }
}

abstract class _Badge implements Badge {
  const factory _Badge(
      {required final String id,
      required final String childId,
      required final BadgeType type,
      required final String name,
      required final String description,
      required final String emoji,
      required final DateTime earnedAt,
      final Map<String, dynamic> metadata}) = _$BadgeImpl;

  factory _Badge.fromJson(Map<String, dynamic> json) = _$BadgeImpl.fromJson;

  @override
  String get id;
  @override
  String get childId;
  @override
  BadgeType get type;
  @override
  String get name;
  @override
  String get description;
  @override
  String get emoji;
  @override
  DateTime get earnedAt;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RewardSystem _$RewardSystemFromJson(Map<String, dynamic> json) {
  return _RewardSystem.fromJson(json);
}

/// @nodoc
mixin _$RewardSystem {
  String get childId => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  int get totalStars => throw _privateConstructorUsedError;
  List<String> get unlockedBadges => throw _privateConstructorUsedError;
  DateTime? get lastActivityAt => throw _privateConstructorUsedError;

  /// Serializes this RewardSystem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RewardSystem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RewardSystemCopyWith<RewardSystem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RewardSystemCopyWith<$Res> {
  factory $RewardSystemCopyWith(
          RewardSystem value, $Res Function(RewardSystem) then) =
      _$RewardSystemCopyWithImpl<$Res, RewardSystem>;
  @useResult
  $Res call(
      {String childId,
      int currentStreak,
      int longestStreak,
      int totalStars,
      List<String> unlockedBadges,
      DateTime? lastActivityAt});
}

/// @nodoc
class _$RewardSystemCopyWithImpl<$Res, $Val extends RewardSystem>
    implements $RewardSystemCopyWith<$Res> {
  _$RewardSystemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RewardSystem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? totalStars = null,
    Object? unlockedBadges = null,
    Object? lastActivityAt = freezed,
  }) {
    return _then(_value.copyWith(
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalStars: null == totalStars
          ? _value.totalStars
          : totalStars // ignore: cast_nullable_to_non_nullable
              as int,
      unlockedBadges: null == unlockedBadges
          ? _value.unlockedBadges
          : unlockedBadges // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastActivityAt: freezed == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RewardSystemImplCopyWith<$Res>
    implements $RewardSystemCopyWith<$Res> {
  factory _$$RewardSystemImplCopyWith(
          _$RewardSystemImpl value, $Res Function(_$RewardSystemImpl) then) =
      __$$RewardSystemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String childId,
      int currentStreak,
      int longestStreak,
      int totalStars,
      List<String> unlockedBadges,
      DateTime? lastActivityAt});
}

/// @nodoc
class __$$RewardSystemImplCopyWithImpl<$Res>
    extends _$RewardSystemCopyWithImpl<$Res, _$RewardSystemImpl>
    implements _$$RewardSystemImplCopyWith<$Res> {
  __$$RewardSystemImplCopyWithImpl(
      _$RewardSystemImpl _value, $Res Function(_$RewardSystemImpl) _then)
      : super(_value, _then);

  /// Create a copy of RewardSystem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? totalStars = null,
    Object? unlockedBadges = null,
    Object? lastActivityAt = freezed,
  }) {
    return _then(_$RewardSystemImpl(
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalStars: null == totalStars
          ? _value.totalStars
          : totalStars // ignore: cast_nullable_to_non_nullable
              as int,
      unlockedBadges: null == unlockedBadges
          ? _value._unlockedBadges
          : unlockedBadges // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastActivityAt: freezed == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RewardSystemImpl implements _RewardSystem {
  const _$RewardSystemImpl(
      {required this.childId,
      this.currentStreak = 0,
      this.longestStreak = 0,
      this.totalStars = 0,
      final List<String> unlockedBadges = const {},
      this.lastActivityAt})
      : _unlockedBadges = unlockedBadges;

  factory _$RewardSystemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RewardSystemImplFromJson(json);

  @override
  final String childId;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int longestStreak;
  @override
  @JsonKey()
  final int totalStars;
  final List<String> _unlockedBadges;
  @override
  @JsonKey()
  List<String> get unlockedBadges {
    if (_unlockedBadges is EqualUnmodifiableListView) return _unlockedBadges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unlockedBadges);
  }

  @override
  final DateTime? lastActivityAt;

  @override
  String toString() {
    return 'RewardSystem(childId: $childId, currentStreak: $currentStreak, longestStreak: $longestStreak, totalStars: $totalStars, unlockedBadges: $unlockedBadges, lastActivityAt: $lastActivityAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RewardSystemImpl &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.totalStars, totalStars) ||
                other.totalStars == totalStars) &&
            const DeepCollectionEquality()
                .equals(other._unlockedBadges, _unlockedBadges) &&
            (identical(other.lastActivityAt, lastActivityAt) ||
                other.lastActivityAt == lastActivityAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      childId,
      currentStreak,
      longestStreak,
      totalStars,
      const DeepCollectionEquality().hash(_unlockedBadges),
      lastActivityAt);

  /// Create a copy of RewardSystem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RewardSystemImplCopyWith<_$RewardSystemImpl> get copyWith =>
      __$$RewardSystemImplCopyWithImpl<_$RewardSystemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RewardSystemImplToJson(
      this,
    );
  }
}

abstract class _RewardSystem implements RewardSystem {
  const factory _RewardSystem(
      {required final String childId,
      final int currentStreak,
      final int longestStreak,
      final int totalStars,
      final List<String> unlockedBadges,
      final DateTime? lastActivityAt}) = _$RewardSystemImpl;

  factory _RewardSystem.fromJson(Map<String, dynamic> json) =
      _$RewardSystemImpl.fromJson;

  @override
  String get childId;
  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  int get totalStars;
  @override
  List<String> get unlockedBadges;
  @override
  DateTime? get lastActivityAt;

  /// Create a copy of RewardSystem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RewardSystemImplCopyWith<_$RewardSystemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
