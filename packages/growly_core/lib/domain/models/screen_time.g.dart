// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScreenTimeRecordImpl _$$ScreenTimeRecordImplFromJson(
        Map<String, dynamic> json) =>
    _$ScreenTimeRecordImpl(
      id: json['id'] as String,
      childId: json['childId'] as String,
      appPackage: json['appPackage'] as String,
      appName: json['appName'] as String?,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ScreenTimeRecordImplToJson(
        _$ScreenTimeRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'appPackage': instance.appPackage,
      'appName': instance.appName,
      'durationMinutes': instance.durationMinutes,
      'date': instance.date.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$DailyScreenTimeImpl _$$DailyScreenTimeImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyScreenTimeImpl(
      childId: json['childId'] as String,
      date: DateTime.parse(json['date'] as String),
      totalMinutes: (json['totalMinutes'] as num).toInt(),
      learningMinutes: (json['learningMinutes'] as num?)?.toInt() ?? 0,
      entertainmentMinutes:
          (json['entertainmentMinutes'] as num?)?.toInt() ?? 0,
      appBreakdown: (json['appBreakdown'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$DailyScreenTimeImplToJson(
        _$DailyScreenTimeImpl instance) =>
    <String, dynamic>{
      'childId': instance.childId,
      'date': instance.date.toIso8601String(),
      'totalMinutes': instance.totalMinutes,
      'learningMinutes': instance.learningMinutes,
      'entertainmentMinutes': instance.entertainmentMinutes,
      'appBreakdown': instance.appBreakdown,
    };

_$ScreenTimeSettingsImpl _$$ScreenTimeSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$ScreenTimeSettingsImpl(
      childId: json['childId'] as String,
      dailyLimitMinutes: (json['dailyLimitMinutes'] as num?)?.toInt() ?? 120,
      isEnabled: json['isEnabled'] as bool? ?? true,
      appLimits: (json['appLimits'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ScreenTimeSettingsImplToJson(
        _$ScreenTimeSettingsImpl instance) =>
    <String, dynamic>{
      'childId': instance.childId,
      'dailyLimitMinutes': instance.dailyLimitMinutes,
      'isEnabled': instance.isEnabled,
      'appLimits': instance.appLimits,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
