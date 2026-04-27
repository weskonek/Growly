// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BadgeImpl _$$BadgeImplFromJson(Map<String, dynamic> json) => _$BadgeImpl(
      id: json['id'] as String,
      childId: json['childId'] as String,
      type: $enumDecode(_$BadgeTypeEnumMap, json['type']),
      name: json['name'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$BadgeImplToJson(_$BadgeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'type': _$BadgeTypeEnumMap[instance.type]!,
      'name': instance.name,
      'description': instance.description,
      'emoji': instance.emoji,
      'earnedAt': instance.earnedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$BadgeTypeEnumMap = {
  BadgeType.streak: 'streak',
  BadgeType.topicMaster: 'topicMaster',
  BadgeType.dailyGoal: 'dailyGoal',
  BadgeType.weeklyGoal: 'weeklyGoal',
  BadgeType.learningHours: 'learningHours',
  BadgeType.perfectScore: 'perfectScore',
  BadgeType.consistent: 'consistent',
  BadgeType.explorer: 'explorer',
};

_$RewardSystemImpl _$$RewardSystemImplFromJson(Map<String, dynamic> json) =>
    _$RewardSystemImpl(
      childId: json['childId'] as String,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      totalStars: (json['totalStars'] as num?)?.toInt() ?? 0,
      unlockedBadges: (json['unlockedBadges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const {},
      lastActivityAt: json['lastActivityAt'] == null
          ? null
          : DateTime.parse(json['lastActivityAt'] as String),
    );

Map<String, dynamic> _$$RewardSystemImplToJson(_$RewardSystemImpl instance) =>
    <String, dynamic>{
      'childId': instance.childId,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'totalStars': instance.totalStars,
      'unlockedBadges': instance.unlockedBadges,
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
    };
