import 'package:growly_core/growly_core.dart';

/// Result of badge evaluation after a learning event.
class BadgeEarnResult {
  final List<Badge> newlyEarned;
  final String? celebrationMessage;

  const BadgeEarnResult({
    this.newlyEarned = const [],
    this.celebrationMessage,
  });

  bool get hasNewBadges => newlyEarned.isNotEmpty;
}

/// Service that evaluates badge conditions after every learning event.
/// Called from child app after completeLesson() succeeds.
class BadgeTriggerService {
  const BadgeTriggerService();

  /// Evaluate badge conditions for a child.
  ///
  /// All condition flags are derived from current session + cumulative stats:
  /// - `currentStreak`: current consecutive-day streak count
  /// - `sessionsToday`: how many sessions child completed today
  /// - `completedAllInTopic`: whether all lessons in the current topic are done
  /// - `allAnswersCorrect`: child got 100% in this session's quiz
  /// - `topicsExplored`: total unique topics child has started learning
  /// - `totalHoursToday`: total learning minutes today / 60
  Future<BadgeEarnResult> evaluate({
    required String childId,
    required int currentStreak,
    required int sessionsToday,
    required bool completedAllInTopic,
    required bool allAnswersCorrect,
    required int topicsExplored,
    required int totalMinutesToday,
    required List<Badge> existingBadges,
  }) async {
    final earned = <Badge>[];
    final now = DateTime.now();

    // ── Streak badges ──────────────────────────────────────────────
    final streakBadges = existingBadges.where((b) => b.type == BadgeType.streak).toList();

    if (currentStreak >= 3 && !_hasStreakWithDays(streakBadges, 3)) {
      earned.add(_makeBadge(
        childId: childId,
        type: BadgeType.streak,
        name: 'Streak 3 Hari',
        description: 'Belajar 3 hari berturut-turut!',
        emoji: '🔥',
        metadata: {'days': 3},
        earnedAt: now,
      ));
    }
    if (currentStreak >= 7 && !_hasStreakWithDays(streakBadges, 7)) {
      earned.add(_makeBadge(
        childId: childId,
        type: BadgeType.streak,
        name: 'Streak 7 Hari',
        description: 'Hebat! 7 hari belajar tanpa putus!',
        emoji: '🔥',
        metadata: {'days': 7},
        earnedAt: now,
      ));
    }
    if (currentStreak >= 30 && !_hasStreakWithDays(streakBadges, 30)) {
      earned.add(_makeBadge(
        childId: childId,
        type: BadgeType.streak,
        name: 'Streak 30 Hari',
        description: 'Luar biasa! Sebulan penuh belajar!',
        emoji: '🔥',
        metadata: {'days': 30},
        earnedAt: now,
      ));
    }

    // ── Topic Master badge ─────────────────────────────────────────
    final hasTopicMaster = existingBadges.any((b) => b.type == BadgeType.topicMaster);
    if (completedAllInTopic && !hasTopicMaster) {
      earned.add(_makeBadge(
        childId: childId,
        type: BadgeType.topicMaster,
        name: 'Master Topik',
        description: 'Menyelesaikan semua pelajaran di satu topik!',
        emoji: '🎓',
        metadata: {},
        earnedAt: now,
      ));
    }

    // ── Daily goal badge ────────────────────────────────────────────
    final hasDailyGoal = existingBadges.any((b) => b.type == BadgeType.dailyGoal);
    if (sessionsToday >= 1 && !hasDailyGoal) {
      earned.add(_makeBadge(
        childId: childId,
        type: BadgeType.dailyGoal,
        name: 'Target Harian',
        description: 'Memenuhi target belajar hari ini!',
        emoji: '✅',
        metadata: {},
        earnedAt: now,
      ));
    }

    // ── Weekly goal badge ───────────────────────────────────────────
    final hasWeeklyGoal = existingBadges.any((b) => b.type == BadgeType.weeklyGoal);
    if (sessionsToday >= 7 && !hasWeeklyGoal) {
      earned.add(_makeBadge(
        childId: childId,
        type: BadgeType.weeklyGoal,
        name: 'Target Mingguan',
        description: 'Belajar setiap hari selama seminggu penuh!',
        emoji: '📅',
        metadata: {},
        earnedAt: now,
      ));
    }

    // ── Perfect score badge ─────────────────────────────────────────
    final hasPerfect = existingBadges.any((b) => b.type == BadgeType.perfectScore);
    if (allAnswersCorrect && !hasPerfect) {
      earned.add(_makeBadge(
        childId: childId,
        type: BadgeType.perfectScore,
        name: 'Skor Sempurna',
        description: 'Dapat nilai 100%! Hebat sekali!',
        emoji: '⭐',
        metadata: {},
        earnedAt: now,
      ));
    }

    // ── Explorer badge ───────────────────────────────────────────────
    final hasExplorer = existingBadges.any((b) => b.type == BadgeType.explorer);
    if (topicsExplored >= 3 && !hasExplorer) {
      earned.add(_makeBadge(
        childId: childId,
        type: BadgeType.explorer,
        name: 'Penjelajah',
        description: 'Mencoba 3 topik berbeda!',
        emoji: '🗺️',
        metadata: {},
        earnedAt: now,
      ));
    }

    // ── Learning hours badge ────────────────────────────────────────
    final hasHours = existingBadges.any((b) => b.type == BadgeType.learningHours);
    if (totalMinutesToday >= 60 && !hasHours) {
      earned.add(_makeBadge(
        childId: childId,
        type: BadgeType.learningHours,
        name: 'Jam Belajar',
        description: 'Belajar selama 1 jam hari ini!',
        emoji: '⏱️',
        metadata: {},
        earnedAt: now,
      ));
    }

    // ── Consistent badge (7 consecutive days active) ───────────────
    final hasConsistent = existingBadges.any((b) => b.type == BadgeType.consistent);
    if (currentStreak >= 7 && !hasConsistent) {
      earned.add(_makeBadge(
        childId: childId,
        type: BadgeType.consistent,
        name: 'Konsisten',
        description: 'Belajar rutin selama seminggu!',
        emoji: '📈',
        metadata: {},
        earnedAt: now,
      ));
    }

    final message = earned.isNotEmpty
        ? _buildCelebrationMessage(earned)
        : null;

    return BadgeEarnResult(newlyEarned: earned, celebrationMessage: message);
  }

  Badge _makeBadge({
    required String childId,
    required BadgeType type,
    required String name,
    required String description,
    required String emoji,
    required Map<String, dynamic> metadata,
    required DateTime earnedAt,
  }) {
    return Badge(
      id: '', // repo will assign
      childId: childId,
      type: type,
      name: name,
      description: description,
      emoji: emoji,
      earnedAt: earnedAt,
      metadata: metadata,
    );
  }

  bool _hasStreakWithDays(List<Badge> streakBadges, int days) {
    return streakBadges.any((b) =>
      (b.metadata['days'] as int?) == days
    );
  }

  String _buildCelebrationMessage(List<Badge> badges) {
    if (badges.length == 1) {
      return '${badges.first.emoji} "${badges.first.name}" diraih!';
    }
    final names = badges.map((b) => '${b.emoji} ${b.name}').join(', ');
    return 'Badge baru diraih: $names';
  }
}