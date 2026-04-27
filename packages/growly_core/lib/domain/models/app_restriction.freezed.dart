// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_restriction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppRestriction _$AppRestrictionFromJson(Map<String, dynamic> json) {
  return _AppRestriction.fromJson(json);
}

/// @nodoc
mixin _$AppRestriction {
  String get id => throw _privateConstructorUsedError;
  String get childId => throw _privateConstructorUsedError;
  String get appPackage => throw _privateConstructorUsedError;
  String? get appName => throw _privateConstructorUsedError;
  String? get appIcon => throw _privateConstructorUsedError;
  bool get isAllowed => throw _privateConstructorUsedError;
  int? get timeLimitMinutes => throw _privateConstructorUsedError;
  Map<String, int> get scheduleLimits => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AppRestriction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppRestriction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppRestrictionCopyWith<AppRestriction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppRestrictionCopyWith<$Res> {
  factory $AppRestrictionCopyWith(
          AppRestriction value, $Res Function(AppRestriction) then) =
      _$AppRestrictionCopyWithImpl<$Res, AppRestriction>;
  @useResult
  $Res call(
      {String id,
      String childId,
      String appPackage,
      String? appName,
      String? appIcon,
      bool isAllowed,
      int? timeLimitMinutes,
      Map<String, int> scheduleLimits,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$AppRestrictionCopyWithImpl<$Res, $Val extends AppRestriction>
    implements $AppRestrictionCopyWith<$Res> {
  _$AppRestrictionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppRestriction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? appPackage = null,
    Object? appName = freezed,
    Object? appIcon = freezed,
    Object? isAllowed = null,
    Object? timeLimitMinutes = freezed,
    Object? scheduleLimits = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
      appPackage: null == appPackage
          ? _value.appPackage
          : appPackage // ignore: cast_nullable_to_non_nullable
              as String,
      appName: freezed == appName
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String?,
      appIcon: freezed == appIcon
          ? _value.appIcon
          : appIcon // ignore: cast_nullable_to_non_nullable
              as String?,
      isAllowed: null == isAllowed
          ? _value.isAllowed
          : isAllowed // ignore: cast_nullable_to_non_nullable
              as bool,
      timeLimitMinutes: freezed == timeLimitMinutes
          ? _value.timeLimitMinutes
          : timeLimitMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      scheduleLimits: null == scheduleLimits
          ? _value.scheduleLimits
          : scheduleLimits // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppRestrictionImplCopyWith<$Res>
    implements $AppRestrictionCopyWith<$Res> {
  factory _$$AppRestrictionImplCopyWith(_$AppRestrictionImpl value,
          $Res Function(_$AppRestrictionImpl) then) =
      __$$AppRestrictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String childId,
      String appPackage,
      String? appName,
      String? appIcon,
      bool isAllowed,
      int? timeLimitMinutes,
      Map<String, int> scheduleLimits,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$AppRestrictionImplCopyWithImpl<$Res>
    extends _$AppRestrictionCopyWithImpl<$Res, _$AppRestrictionImpl>
    implements _$$AppRestrictionImplCopyWith<$Res> {
  __$$AppRestrictionImplCopyWithImpl(
      _$AppRestrictionImpl _value, $Res Function(_$AppRestrictionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppRestriction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? appPackage = null,
    Object? appName = freezed,
    Object? appIcon = freezed,
    Object? isAllowed = null,
    Object? timeLimitMinutes = freezed,
    Object? scheduleLimits = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AppRestrictionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      appPackage: null == appPackage
          ? _value.appPackage
          : appPackage // ignore: cast_nullable_to_non_nullable
              as String,
      appName: freezed == appName
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String?,
      appIcon: freezed == appIcon
          ? _value.appIcon
          : appIcon // ignore: cast_nullable_to_non_nullable
              as String?,
      isAllowed: null == isAllowed
          ? _value.isAllowed
          : isAllowed // ignore: cast_nullable_to_non_nullable
              as bool,
      timeLimitMinutes: freezed == timeLimitMinutes
          ? _value.timeLimitMinutes
          : timeLimitMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      scheduleLimits: null == scheduleLimits
          ? _value._scheduleLimits
          : scheduleLimits // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppRestrictionImpl implements _AppRestriction {
  const _$AppRestrictionImpl(
      {required this.id,
      required this.childId,
      required this.appPackage,
      this.appName,
      this.appIcon,
      required this.isAllowed,
      this.timeLimitMinutes = null,
      final Map<String, int> scheduleLimits = const {},
      required this.createdAt,
      this.updatedAt})
      : _scheduleLimits = scheduleLimits;

  factory _$AppRestrictionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppRestrictionImplFromJson(json);

  @override
  final String id;
  @override
  final String childId;
  @override
  final String appPackage;
  @override
  final String? appName;
  @override
  final String? appIcon;
  @override
  final bool isAllowed;
  @override
  @JsonKey()
  final int? timeLimitMinutes;
  final Map<String, int> _scheduleLimits;
  @override
  @JsonKey()
  Map<String, int> get scheduleLimits {
    if (_scheduleLimits is EqualUnmodifiableMapView) return _scheduleLimits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scheduleLimits);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AppRestriction(id: $id, childId: $childId, appPackage: $appPackage, appName: $appName, appIcon: $appIcon, isAllowed: $isAllowed, timeLimitMinutes: $timeLimitMinutes, scheduleLimits: $scheduleLimits, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppRestrictionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.appPackage, appPackage) ||
                other.appPackage == appPackage) &&
            (identical(other.appName, appName) || other.appName == appName) &&
            (identical(other.appIcon, appIcon) || other.appIcon == appIcon) &&
            (identical(other.isAllowed, isAllowed) ||
                other.isAllowed == isAllowed) &&
            (identical(other.timeLimitMinutes, timeLimitMinutes) ||
                other.timeLimitMinutes == timeLimitMinutes) &&
            const DeepCollectionEquality()
                .equals(other._scheduleLimits, _scheduleLimits) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      childId,
      appPackage,
      appName,
      appIcon,
      isAllowed,
      timeLimitMinutes,
      const DeepCollectionEquality().hash(_scheduleLimits),
      createdAt,
      updatedAt);

  /// Create a copy of AppRestriction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppRestrictionImplCopyWith<_$AppRestrictionImpl> get copyWith =>
      __$$AppRestrictionImplCopyWithImpl<_$AppRestrictionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppRestrictionImplToJson(
      this,
    );
  }
}

abstract class _AppRestriction implements AppRestriction {
  const factory _AppRestriction(
      {required final String id,
      required final String childId,
      required final String appPackage,
      final String? appName,
      final String? appIcon,
      required final bool isAllowed,
      final int? timeLimitMinutes,
      final Map<String, int> scheduleLimits,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$AppRestrictionImpl;

  factory _AppRestriction.fromJson(Map<String, dynamic> json) =
      _$AppRestrictionImpl.fromJson;

  @override
  String get id;
  @override
  String get childId;
  @override
  String get appPackage;
  @override
  String? get appName;
  @override
  String? get appIcon;
  @override
  bool get isAllowed;
  @override
  int? get timeLimitMinutes;
  @override
  Map<String, int> get scheduleLimits;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of AppRestriction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppRestrictionImplCopyWith<_$AppRestrictionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Schedule _$ScheduleFromJson(Map<String, dynamic> json) {
  return _Schedule.fromJson(json);
}

/// @nodoc
mixin _$Schedule {
  String get id => throw _privateConstructorUsedError;
  String get childId => throw _privateConstructorUsedError;
  int get dayOfWeek =>
      throw _privateConstructorUsedError; // 1 = Monday, 7 = Sunday
  String get startTime => throw _privateConstructorUsedError; // HH:mm format
  String get endTime => throw _privateConstructorUsedError; // HH:mm format
  String get mode =>
      throw _privateConstructorUsedError; // learning, break, school, sleep
  bool get isEnabled => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Schedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleCopyWith<Schedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleCopyWith<$Res> {
  factory $ScheduleCopyWith(Schedule value, $Res Function(Schedule) then) =
      _$ScheduleCopyWithImpl<$Res, Schedule>;
  @useResult
  $Res call(
      {String id,
      String childId,
      int dayOfWeek,
      String startTime,
      String endTime,
      String mode,
      bool isEnabled,
      String? label,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ScheduleCopyWithImpl<$Res, $Val extends Schedule>
    implements $ScheduleCopyWith<$Res> {
  _$ScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? mode = null,
    Object? isEnabled = null,
    Object? label = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleImplCopyWith<$Res>
    implements $ScheduleCopyWith<$Res> {
  factory _$$ScheduleImplCopyWith(
          _$ScheduleImpl value, $Res Function(_$ScheduleImpl) then) =
      __$$ScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String childId,
      int dayOfWeek,
      String startTime,
      String endTime,
      String mode,
      bool isEnabled,
      String? label,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ScheduleImplCopyWithImpl<$Res>
    extends _$ScheduleCopyWithImpl<$Res, _$ScheduleImpl>
    implements _$$ScheduleImplCopyWith<$Res> {
  __$$ScheduleImplCopyWithImpl(
      _$ScheduleImpl _value, $Res Function(_$ScheduleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? mode = null,
    Object? isEnabled = null,
    Object? label = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ScheduleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleImpl implements _Schedule {
  const _$ScheduleImpl(
      {required this.id,
      required this.childId,
      required this.dayOfWeek,
      required this.startTime,
      required this.endTime,
      required this.mode,
      this.isEnabled = true,
      this.label,
      required this.createdAt,
      this.updatedAt});

  factory _$ScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleImplFromJson(json);

  @override
  final String id;
  @override
  final String childId;
  @override
  final int dayOfWeek;
// 1 = Monday, 7 = Sunday
  @override
  final String startTime;
// HH:mm format
  @override
  final String endTime;
// HH:mm format
  @override
  final String mode;
// learning, break, school, sleep
  @override
  @JsonKey()
  final bool isEnabled;
  @override
  final String? label;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Schedule(id: $id, childId: $childId, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, mode: $mode, isEnabled: $isEnabled, label: $label, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, childId, dayOfWeek,
      startTime, endTime, mode, isEnabled, label, createdAt, updatedAt);

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleImplCopyWith<_$ScheduleImpl> get copyWith =>
      __$$ScheduleImplCopyWithImpl<_$ScheduleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleImplToJson(
      this,
    );
  }
}

abstract class _Schedule implements Schedule {
  const factory _Schedule(
      {required final String id,
      required final String childId,
      required final int dayOfWeek,
      required final String startTime,
      required final String endTime,
      required final String mode,
      final bool isEnabled,
      final String? label,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$ScheduleImpl;

  factory _Schedule.fromJson(Map<String, dynamic> json) =
      _$ScheduleImpl.fromJson;

  @override
  String get id;
  @override
  String get childId;
  @override
  int get dayOfWeek; // 1 = Monday, 7 = Sunday
  @override
  String get startTime; // HH:mm format
  @override
  String get endTime; // HH:mm format
  @override
  String get mode; // learning, break, school, sleep
  @override
  bool get isEnabled;
  @override
  String? get label;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleImplCopyWith<_$ScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
