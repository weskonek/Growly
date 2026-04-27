// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_restriction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppRestrictionImpl _$$AppRestrictionImplFromJson(Map<String, dynamic> json) =>
    _$AppRestrictionImpl(
      id: json['id'] as String,
      childId: json['childId'] as String,
      appPackage: json['appPackage'] as String,
      appName: json['appName'] as String?,
      appIcon: json['appIcon'] as String?,
      isAllowed: json['isAllowed'] as bool,
      timeLimitMinutes: (json['timeLimitMinutes'] as num?)?.toInt() ?? null,
      scheduleLimits: (json['scheduleLimits'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AppRestrictionImplToJson(
        _$AppRestrictionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'appPackage': instance.appPackage,
      'appName': instance.appName,
      'appIcon': instance.appIcon,
      'isAllowed': instance.isAllowed,
      'timeLimitMinutes': instance.timeLimitMinutes,
      'scheduleLimits': instance.scheduleLimits,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$ScheduleImpl _$$ScheduleImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleImpl(
      id: json['id'] as String,
      childId: json['childId'] as String,
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      mode: json['mode'] as String,
      isEnabled: json['isEnabled'] as bool? ?? true,
      label: json['label'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ScheduleImplToJson(_$ScheduleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'dayOfWeek': instance.dayOfWeek,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'mode': instance.mode,
      'isEnabled': instance.isEnabled,
      'label': instance.label,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
