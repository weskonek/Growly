import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge.freezed.dart';
part 'badge.g.dart';

enum BadgeType {
  streak,
  topicMaster,
  dailyGoal,
  weeklyGoal,
  learningHours,
  perfectScore,
  consistent,
  explorer,
}

@freezed
class Badge with _$Badge {
  const factory Badge({
    required String id,
    required String childId,
    required BadgeType type,
    required String name,
    required String description,
    required String emoji,
    required DateTime earnedAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}

extension BadgeX on Badge {
  String get typeDisplayName {
    switch (type) {
      case BadgeType.streak:
        return 'Streak';
      case BadgeType.topicMaster:
        return 'Master Topik';
      case BadgeType.dailyGoal:
        return 'Target Harian';
      case BadgeType.weeklyGoal:
        return 'Target Mingguan';
      case BadgeType.learningHours:
        return 'Jam Belajar';
      case BadgeType.perfectScore:
        return 'Skor Sempurna';
      case BadgeType.consistent:
        return 'Konsisten';
      case BadgeType.explorer:
        return 'Penjelajah';
    }
  }
}

@freezed
class RewardSystem with _$RewardSystem {
  const factory RewardSystem({
    required String childId,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0) int totalStars,
    @Default({}) List<String> unlockedBadges,
    DateTime? lastActivityAt,
  }) = _RewardSystem;

  factory RewardSystem.fromJson(Map<String, dynamic> json) =>
      _$RewardSystemFromJson(json);
}