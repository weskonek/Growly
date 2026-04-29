enum QuestType {
  completeSession,
  answerQuestions,
  reachStreak,
  exploreTopic,
}

extension QuestTypeX on QuestType {
  String get key {
    switch (this) {
      case QuestType.completeSession:
        return 'complete_session';
      case QuestType.answerQuestions:
        return 'answer_questions';
      case QuestType.reachStreak:
        return 'reach_streak';
      case QuestType.exploreTopic:
        return 'explore_topic';
    }
  }

  static QuestType fromKey(String key) {
    return QuestType.values.firstWhere(
      (q) => q.key == key,
      orElse: () => QuestType.completeSession,
    );
  }
}

class DailyQuest {
  final String id;
  final QuestType type;
  final String title;
  final String description;
  final String emoji;
  final int starsReward;
  final int targetValue;
  final int currentValue;
  final bool isCompleted;

  const DailyQuest({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.starsReward,
    required this.targetValue,
    this.currentValue = 0,
    this.isCompleted = false,
  });

  double get progress {
    if (targetValue == 0) return 0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  factory DailyQuest.fromJson(Map<String, dynamic> json) {
    final def = json['definition'] as Map<String, dynamic>? ?? {};
    return DailyQuest(
      id: def['quest_id'] as String? ?? json['quest_id'] as String? ?? '',
      type: QuestTypeX.fromKey(def['quest_type'] as String? ?? 'complete_session'),
      title: def['title'] as String? ?? json['title'] as String? ?? '',
      description: def['description'] as String? ?? json['description'] as String? ?? '',
      emoji: def['icon_emoji'] as String? ?? json['emoji'] as String? ?? '📚',
      starsReward: def['stars_reward'] as int? ?? json['stars_reward'] as int? ?? 2,
      targetValue: def['target_value'] as int? ?? json['target_value'] as int? ?? 1,
      currentValue: json['current_value'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? json['is_completed'] == true,
    );
  }
}