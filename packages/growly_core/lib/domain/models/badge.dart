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

extension BadgeTypeX on BadgeType {
  String get displayName {
    switch (this) {
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

class Badge {
  final String id;
  final String childId;
  final BadgeType type;
  final String name;
  final String description;
  final String emoji;
  final DateTime earnedAt;
  final Map<String, dynamic> metadata;

  const Badge({
    required this.id,
    required this.childId,
    required this.type,
    required this.name,
    required this.description,
    required this.emoji,
    required this.earnedAt,
    this.metadata = const {},
  });

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

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      type: BadgeType.values[json['badge_type'] as int? ?? 0],
      name: json['name'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      earnedAt: DateTime.parse(json['earned_at'] as String),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'badge_type': type.index,
      'name': name,
      'description': description,
      'emoji': emoji,
      'earned_at': earnedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  Badge copyWith({
    String? id,
    String? childId,
    BadgeType? type,
    String? name,
    String? description,
    String? emoji,
    DateTime? earnedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Badge(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      earnedAt: earnedAt ?? this.earnedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class RewardSystem {
  final String childId;
  final int currentStreak;
  final int longestStreak;
  final int totalStars;
  final List<String> unlockedBadges;
  final DateTime? lastActivityAt;

  const RewardSystem({
    required this.childId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalStars = 0,
    this.unlockedBadges = const [],
    this.lastActivityAt,
  });

  factory RewardSystem.fromJson(Map<String, dynamic> json) {
    return RewardSystem(
      childId: json['child_id'] as String,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalStars: json['total_stars'] as int? ?? 0,
      unlockedBadges: (json['unlocked_badges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.parse(json['last_activity_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'child_id': childId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_stars': totalStars,
      'unlocked_badges': unlockedBadges,
      'last_activity_at': lastActivityAt?.toIso8601String(),
    };
  }

  RewardSystem copyWith({
    String? childId,
    int? currentStreak,
    int? longestStreak,
    int? totalStars,
    List<String>? unlockedBadges,
    DateTime? lastActivityAt,
  }) {
    return RewardSystem(
      childId: childId ?? this.childId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalStars: totalStars ?? this.totalStars,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}