// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LearningProgressImpl _$$LearningProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$LearningProgressImpl(
      id: json['id'] as String,
      childId: json['childId'] as String,
      subject: json['subject'] as String,
      topic: json['topic'] as String,
      score: (json['score'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      sessionId: json['sessionId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$LearningProgressImplToJson(
        _$LearningProgressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'subject': instance.subject,
      'topic': instance.topic,
      'score': instance.score,
      'completed': instance.completed,
      'completedAt': instance.completedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'sessionId': instance.sessionId,
      'metadata': instance.metadata,
    };

_$LearningSessionImpl _$$LearningSessionImplFromJson(
        Map<String, dynamic> json) =>
    _$LearningSessionImpl(
      id: json['id'] as String,
      childId: json['childId'] as String,
      subject: json['subject'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      topicsCovered: (json['topicsCovered'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$LearningSessionImplToJson(
        _$LearningSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'subject': instance.subject,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'topicsCovered': instance.topicsCovered,
      'data': instance.data,
    };
