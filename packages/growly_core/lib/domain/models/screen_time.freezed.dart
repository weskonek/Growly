// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'screen_time.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScreenTimeRecord _$ScreenTimeRecordFromJson(Map<String, dynamic> json) {
  return _ScreenTimeRecord.fromJson(json);
}

/// @nodoc
mixin _$ScreenTimeRecord {
  String get id => throw _privateConstructorUsedError;
  String get childId => throw _privateConstructorUsedError;
  String get appPackage => throw _privateConstructorUsedError;
  String? get appName => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ScreenTimeRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScreenTimeRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScreenTimeRecordCopyWith<ScreenTimeRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScreenTimeRecordCopyWith<$Res> {
  factory $ScreenTimeRecordCopyWith(
          ScreenTimeRecord value, $Res Function(ScreenTimeRecord) then) =
      _$ScreenTimeRecordCopyWithImpl<$Res, ScreenTimeRecord>;
  @useResult
  $Res call(
      {String id,
      String childId,
      String appPackage,
      String? appName,
      int durationMinutes,
      DateTime date,
      DateTime createdAt});
}

/// @nodoc
class _$ScreenTimeRecordCopyWithImpl<$Res, $Val extends ScreenTimeRecord>
    implements $ScreenTimeRecordCopyWith<$Res> {
  _$ScreenTimeRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScreenTimeRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? appPackage = null,
    Object? appName = freezed,
    Object? durationMinutes = null,
    Object? date = null,
    Object? createdAt = null,
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
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScreenTimeRecordImplCopyWith<$Res>
    implements $ScreenTimeRecordCopyWith<$Res> {
  factory _$$ScreenTimeRecordImplCopyWith(_$ScreenTimeRecordImpl value,
          $Res Function(_$ScreenTimeRecordImpl) then) =
      __$$ScreenTimeRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String childId,
      String appPackage,
      String? appName,
      int durationMinutes,
      DateTime date,
      DateTime createdAt});
}

/// @nodoc
class __$$ScreenTimeRecordImplCopyWithImpl<$Res>
    extends _$ScreenTimeRecordCopyWithImpl<$Res, _$ScreenTimeRecordImpl>
    implements _$$ScreenTimeRecordImplCopyWith<$Res> {
  __$$ScreenTimeRecordImplCopyWithImpl(_$ScreenTimeRecordImpl _value,
      $Res Function(_$ScreenTimeRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScreenTimeRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? appPackage = null,
    Object? appName = freezed,
    Object? durationMinutes = null,
    Object? date = null,
    Object? createdAt = null,
  }) {
    return _then(_$ScreenTimeRecordImpl(
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
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScreenTimeRecordImpl implements _ScreenTimeRecord {
  const _$ScreenTimeRecordImpl(
      {required this.id,
      required this.childId,
      required this.appPackage,
      this.appName,
      required this.durationMinutes,
      required this.date,
      required this.createdAt});

  factory _$ScreenTimeRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScreenTimeRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String childId;
  @override
  final String appPackage;
  @override
  final String? appName;
  @override
  final int durationMinutes;
  @override
  final DateTime date;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ScreenTimeRecord(id: $id, childId: $childId, appPackage: $appPackage, appName: $appName, durationMinutes: $durationMinutes, date: $date, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScreenTimeRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.appPackage, appPackage) ||
                other.appPackage == appPackage) &&
            (identical(other.appName, appName) || other.appName == appName) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, childId, appPackage, appName,
      durationMinutes, date, createdAt);

  /// Create a copy of ScreenTimeRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScreenTimeRecordImplCopyWith<_$ScreenTimeRecordImpl> get copyWith =>
      __$$ScreenTimeRecordImplCopyWithImpl<_$ScreenTimeRecordImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScreenTimeRecordImplToJson(
      this,
    );
  }
}

abstract class _ScreenTimeRecord implements ScreenTimeRecord {
  const factory _ScreenTimeRecord(
      {required final String id,
      required final String childId,
      required final String appPackage,
      final String? appName,
      required final int durationMinutes,
      required final DateTime date,
      required final DateTime createdAt}) = _$ScreenTimeRecordImpl;

  factory _ScreenTimeRecord.fromJson(Map<String, dynamic> json) =
      _$ScreenTimeRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get childId;
  @override
  String get appPackage;
  @override
  String? get appName;
  @override
  int get durationMinutes;
  @override
  DateTime get date;
  @override
  DateTime get createdAt;

  /// Create a copy of ScreenTimeRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScreenTimeRecordImplCopyWith<_$ScreenTimeRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyScreenTime _$DailyScreenTimeFromJson(Map<String, dynamic> json) {
  return _DailyScreenTime.fromJson(json);
}

/// @nodoc
mixin _$DailyScreenTime {
  String get childId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  int get totalMinutes => throw _privateConstructorUsedError;
  int get learningMinutes => throw _privateConstructorUsedError;
  int get entertainmentMinutes => throw _privateConstructorUsedError;
  Map<String, int> get appBreakdown => throw _privateConstructorUsedError;

  /// Serializes this DailyScreenTime to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyScreenTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyScreenTimeCopyWith<DailyScreenTime> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyScreenTimeCopyWith<$Res> {
  factory $DailyScreenTimeCopyWith(
          DailyScreenTime value, $Res Function(DailyScreenTime) then) =
      _$DailyScreenTimeCopyWithImpl<$Res, DailyScreenTime>;
  @useResult
  $Res call(
      {String childId,
      DateTime date,
      int totalMinutes,
      int learningMinutes,
      int entertainmentMinutes,
      Map<String, int> appBreakdown});
}

/// @nodoc
class _$DailyScreenTimeCopyWithImpl<$Res, $Val extends DailyScreenTime>
    implements $DailyScreenTimeCopyWith<$Res> {
  _$DailyScreenTimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyScreenTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? date = null,
    Object? totalMinutes = null,
    Object? learningMinutes = null,
    Object? entertainmentMinutes = null,
    Object? appBreakdown = null,
  }) {
    return _then(_value.copyWith(
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      learningMinutes: null == learningMinutes
          ? _value.learningMinutes
          : learningMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      entertainmentMinutes: null == entertainmentMinutes
          ? _value.entertainmentMinutes
          : entertainmentMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      appBreakdown: null == appBreakdown
          ? _value.appBreakdown
          : appBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyScreenTimeImplCopyWith<$Res>
    implements $DailyScreenTimeCopyWith<$Res> {
  factory _$$DailyScreenTimeImplCopyWith(_$DailyScreenTimeImpl value,
          $Res Function(_$DailyScreenTimeImpl) then) =
      __$$DailyScreenTimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String childId,
      DateTime date,
      int totalMinutes,
      int learningMinutes,
      int entertainmentMinutes,
      Map<String, int> appBreakdown});
}

/// @nodoc
class __$$DailyScreenTimeImplCopyWithImpl<$Res>
    extends _$DailyScreenTimeCopyWithImpl<$Res, _$DailyScreenTimeImpl>
    implements _$$DailyScreenTimeImplCopyWith<$Res> {
  __$$DailyScreenTimeImplCopyWithImpl(
      _$DailyScreenTimeImpl _value, $Res Function(_$DailyScreenTimeImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyScreenTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? date = null,
    Object? totalMinutes = null,
    Object? learningMinutes = null,
    Object? entertainmentMinutes = null,
    Object? appBreakdown = null,
  }) {
    return _then(_$DailyScreenTimeImpl(
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      learningMinutes: null == learningMinutes
          ? _value.learningMinutes
          : learningMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      entertainmentMinutes: null == entertainmentMinutes
          ? _value.entertainmentMinutes
          : entertainmentMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      appBreakdown: null == appBreakdown
          ? _value._appBreakdown
          : appBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyScreenTimeImpl implements _DailyScreenTime {
  const _$DailyScreenTimeImpl(
      {required this.childId,
      required this.date,
      required this.totalMinutes,
      this.learningMinutes = 0,
      this.entertainmentMinutes = 0,
      final Map<String, int> appBreakdown = const {}})
      : _appBreakdown = appBreakdown;

  factory _$DailyScreenTimeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyScreenTimeImplFromJson(json);

  @override
  final String childId;
  @override
  final DateTime date;
  @override
  final int totalMinutes;
  @override
  @JsonKey()
  final int learningMinutes;
  @override
  @JsonKey()
  final int entertainmentMinutes;
  final Map<String, int> _appBreakdown;
  @override
  @JsonKey()
  Map<String, int> get appBreakdown {
    if (_appBreakdown is EqualUnmodifiableMapView) return _appBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_appBreakdown);
  }

  @override
  String toString() {
    return 'DailyScreenTime(childId: $childId, date: $date, totalMinutes: $totalMinutes, learningMinutes: $learningMinutes, entertainmentMinutes: $entertainmentMinutes, appBreakdown: $appBreakdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyScreenTimeImpl &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            (identical(other.learningMinutes, learningMinutes) ||
                other.learningMinutes == learningMinutes) &&
            (identical(other.entertainmentMinutes, entertainmentMinutes) ||
                other.entertainmentMinutes == entertainmentMinutes) &&
            const DeepCollectionEquality()
                .equals(other._appBreakdown, _appBreakdown));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      childId,
      date,
      totalMinutes,
      learningMinutes,
      entertainmentMinutes,
      const DeepCollectionEquality().hash(_appBreakdown));

  /// Create a copy of DailyScreenTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyScreenTimeImplCopyWith<_$DailyScreenTimeImpl> get copyWith =>
      __$$DailyScreenTimeImplCopyWithImpl<_$DailyScreenTimeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyScreenTimeImplToJson(
      this,
    );
  }
}

abstract class _DailyScreenTime implements DailyScreenTime {
  const factory _DailyScreenTime(
      {required final String childId,
      required final DateTime date,
      required final int totalMinutes,
      final int learningMinutes,
      final int entertainmentMinutes,
      final Map<String, int> appBreakdown}) = _$DailyScreenTimeImpl;

  factory _DailyScreenTime.fromJson(Map<String, dynamic> json) =
      _$DailyScreenTimeImpl.fromJson;

  @override
  String get childId;
  @override
  DateTime get date;
  @override
  int get totalMinutes;
  @override
  int get learningMinutes;
  @override
  int get entertainmentMinutes;
  @override
  Map<String, int> get appBreakdown;

  /// Create a copy of DailyScreenTime
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyScreenTimeImplCopyWith<_$DailyScreenTimeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScreenTimeSettings _$ScreenTimeSettingsFromJson(Map<String, dynamic> json) {
  return _ScreenTimeSettings.fromJson(json);
}

/// @nodoc
mixin _$ScreenTimeSettings {
  String get childId => throw _privateConstructorUsedError;
  int get dailyLimitMinutes => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;
  Map<String, int> get appLimits => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ScreenTimeSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScreenTimeSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScreenTimeSettingsCopyWith<ScreenTimeSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScreenTimeSettingsCopyWith<$Res> {
  factory $ScreenTimeSettingsCopyWith(
          ScreenTimeSettings value, $Res Function(ScreenTimeSettings) then) =
      _$ScreenTimeSettingsCopyWithImpl<$Res, ScreenTimeSettings>;
  @useResult
  $Res call(
      {String childId,
      int dailyLimitMinutes,
      bool isEnabled,
      Map<String, int> appLimits,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ScreenTimeSettingsCopyWithImpl<$Res, $Val extends ScreenTimeSettings>
    implements $ScreenTimeSettingsCopyWith<$Res> {
  _$ScreenTimeSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScreenTimeSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? dailyLimitMinutes = null,
    Object? isEnabled = null,
    Object? appLimits = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      dailyLimitMinutes: null == dailyLimitMinutes
          ? _value.dailyLimitMinutes
          : dailyLimitMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      appLimits: null == appLimits
          ? _value.appLimits
          : appLimits // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ScreenTimeSettingsImplCopyWith<$Res>
    implements $ScreenTimeSettingsCopyWith<$Res> {
  factory _$$ScreenTimeSettingsImplCopyWith(_$ScreenTimeSettingsImpl value,
          $Res Function(_$ScreenTimeSettingsImpl) then) =
      __$$ScreenTimeSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String childId,
      int dailyLimitMinutes,
      bool isEnabled,
      Map<String, int> appLimits,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ScreenTimeSettingsImplCopyWithImpl<$Res>
    extends _$ScreenTimeSettingsCopyWithImpl<$Res, _$ScreenTimeSettingsImpl>
    implements _$$ScreenTimeSettingsImplCopyWith<$Res> {
  __$$ScreenTimeSettingsImplCopyWithImpl(_$ScreenTimeSettingsImpl _value,
      $Res Function(_$ScreenTimeSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScreenTimeSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? dailyLimitMinutes = null,
    Object? isEnabled = null,
    Object? appLimits = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ScreenTimeSettingsImpl(
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      dailyLimitMinutes: null == dailyLimitMinutes
          ? _value.dailyLimitMinutes
          : dailyLimitMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      appLimits: null == appLimits
          ? _value._appLimits
          : appLimits // ignore: cast_nullable_to_non_nullable
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
class _$ScreenTimeSettingsImpl implements _ScreenTimeSettings {
  const _$ScreenTimeSettingsImpl(
      {required this.childId,
      this.dailyLimitMinutes = 120,
      this.isEnabled = true,
      final Map<String, int> appLimits = const {},
      required this.createdAt,
      this.updatedAt})
      : _appLimits = appLimits;

  factory _$ScreenTimeSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScreenTimeSettingsImplFromJson(json);

  @override
  final String childId;
  @override
  @JsonKey()
  final int dailyLimitMinutes;
  @override
  @JsonKey()
  final bool isEnabled;
  final Map<String, int> _appLimits;
  @override
  @JsonKey()
  Map<String, int> get appLimits {
    if (_appLimits is EqualUnmodifiableMapView) return _appLimits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_appLimits);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ScreenTimeSettings(childId: $childId, dailyLimitMinutes: $dailyLimitMinutes, isEnabled: $isEnabled, appLimits: $appLimits, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScreenTimeSettingsImpl &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.dailyLimitMinutes, dailyLimitMinutes) ||
                other.dailyLimitMinutes == dailyLimitMinutes) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            const DeepCollectionEquality()
                .equals(other._appLimits, _appLimits) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      childId,
      dailyLimitMinutes,
      isEnabled,
      const DeepCollectionEquality().hash(_appLimits),
      createdAt,
      updatedAt);

  /// Create a copy of ScreenTimeSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScreenTimeSettingsImplCopyWith<_$ScreenTimeSettingsImpl> get copyWith =>
      __$$ScreenTimeSettingsImplCopyWithImpl<_$ScreenTimeSettingsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScreenTimeSettingsImplToJson(
      this,
    );
  }
}

abstract class _ScreenTimeSettings implements ScreenTimeSettings {
  const factory _ScreenTimeSettings(
      {required final String childId,
      final int dailyLimitMinutes,
      final bool isEnabled,
      final Map<String, int> appLimits,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$ScreenTimeSettingsImpl;

  factory _ScreenTimeSettings.fromJson(Map<String, dynamic> json) =
      _$ScreenTimeSettingsImpl.fromJson;

  @override
  String get childId;
  @override
  int get dailyLimitMinutes;
  @override
  bool get isEnabled;
  @override
  Map<String, int> get appLimits;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ScreenTimeSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScreenTimeSettingsImplCopyWith<_$ScreenTimeSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
