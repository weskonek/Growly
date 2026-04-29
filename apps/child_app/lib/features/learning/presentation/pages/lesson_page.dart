import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:growly_core/growly_core.dart' hide learningRepositoryProvider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:child_app/features/learning/providers/learning_providers.dart';
import 'package:child_app/features/rewards/providers/rewards_providers.dart';
import 'package:child_app/core/router/child_router.dart' show verifiedChildIdProvider;

class LessonPage extends ConsumerStatefulWidget {
  final String subjectId;
  final String lessonId;

  const LessonPage({
    super.key,
    required this.subjectId,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  int _currentStep = 0;
  List<Map<String, String>> _steps = [];
  bool _completed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    final repository = ref.read(learningRepositoryProvider);
    final childId = ref.read(verifiedChildIdProvider);
    if (childId == null) return;

    // Start session
    ref.read(learningSessionProvider.notifier).startSession(widget.subjectId);

    // Load lesson content from DB
    final (lesson, lessonError) = await repository.getLesson(widget.lessonId);
    if (!mounted) return;

    if (lessonError != null || lesson == null) {
      // Fallback: static intro steps if DB lesson not found
      setState(() {
        _steps = [
          {'title': 'Yuk mulai belajar!', 'content': 'Perhatikan baik-baik ya!'},
          {'title': 'Waktunya Latihan!', 'content': 'Sekarang kamu coba sendiri ya!'},
        ];
        _loading = false;
      });
      return;
    }

    final stepsData = lesson['steps'] as List<dynamic>;
    setState(() {
      _steps = stepsData
          .map((s) => {
                'title': s['title'] as String,
                'content': s['content'] as String,
              })
          .toList();
      _loading = false;
    });
  }

  @override
  void dispose() {
    // Schedule endSession as a microtask so it fires after the widget tree is disposed
    // without awaiting inside dispose(). Safe because endSession is idempotent.
    Future.microtask(() async {
      final sessionId = ref.read(learningSessionProvider).valueOrNull;
      if (sessionId != null) {
        final repository = ref.read(learningRepositoryProvider);
        // We can't get _sessionStart here, so pass 0 — duration is approximate
        await repository.endSession(sessionId, durationMinutes: 0);
      }
    });
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _completeLesson();
    }
  }

  Future<void> _completeLesson() async {
    if (_completed) return;
    final childId = ref.read(verifiedChildIdProvider);
    if (childId == null) return;

    setState(() => _completed = true);

    final badgeRepo = ref.read(badgeRepositoryProvider);
    final badgeService = const BadgeTriggerService();

    // ── Load current stats for badge evaluation ──────────────────
    final (reward, _) = await badgeRepo.getRewardSystem(childId);
    final (badges, _) = await badgeRepo.getBadges(childId);
    final existingBadges = badges ?? [];
    final todaySessions = await _getTodaySessionCount(childId);

    // ── Complete lesson in DB (atomic streak + stars update) ────────
    await badgeRepo.completeLesson(childId, widget.lessonId, 10);

    // ── Evaluate badge triggers ───────────────────────────────────
    final result = await badgeService.evaluate(
      childId: childId,
      currentStreak: reward?.currentStreak ?? 0,
      sessionsToday: todaySessions,
      completedAllInTopic: false, // TODO: check if topic fully completed
      allAnswersCorrect: false,   // TODO: wire from quiz result
      topicsExplored: 1,          // TODO: count from learning_progress
      totalMinutesToday: 0,       // TODO: sum from learning_sessions
      existingBadges: existingBadges,
    );

    // ── Award newly earned badges + insert parent notification ──────
    for (final badge in result.newlyEarned) {
      await badgeRepo.awardBadge(badge);
      if (mounted) await _notifyParent(childId, badge.name, badge.emoji);
    }

    // ── Refresh rewards UI ─────────────────────────────────────────
    ref.invalidate(badgesProvider);
    ref.invalidate(rewardSystemProvider);

    if (!mounted) return;

    // ── Show celebration if badges earned ──────────────────────────
    if (result.hasNewBadges) {
      await _showBadgeCelebration(context, result);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hebat! Kamu sudah selesai belajar! 🎉')),
    );
    context.go('/learning/subject/${widget.subjectId}');
  }

  Future<int> _getTodaySessionCount(String childId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final resp = await Supabase.instance.client
          .from('learning_sessions')
          .select('id')
          .eq('child_id', childId)
          .gte('started_at', '${today}T00:00:00');
      return (resp as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _notifyParent(String childId, String badgeName, String badgeEmoji) async {
    try {
      // Look up parent_id for this child, then insert notification
      final childResp = await Supabase.instance.client
          .from('child_profiles')
          .select('parent_id')
          .eq('id', childId)
          .maybeSingle();
      if (childResp == null) return;
      final parentId = childResp['parent_id'] as String?;
      if (parentId == null) return;

      await Supabase.instance.client.from('notifications').insert({
        'parent_id': parentId,
        'title': '$badgeEmoji Badge Diraih!',
        'body': ' anak berhasil mendapat badge "$badgeName". Lihat di menu Anak!',
        'type': 'achievement',
        'is_read': false,
      });
    } catch (_) {}
  }

  Future<void> _showBadgeCelebration(BuildContext context, BadgeEarnResult result) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          const Text('🎉'),
          const SizedBox(width: 8),
          const Text('Badge Diraih!'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final badge in result.newlyEarned)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Text(badge.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(child: Text(badge.name, style: const TextStyle(fontSize: 16))),
              ]),
            ),
          const SizedBox(height: 8),
          if (result.celebrationMessage != null)
            Text(result.celebrationMessage!, style: const TextStyle(fontStyle: FontStyle.italic)),
        ]),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hebat! 🔥'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Belajar')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Belajar')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Konten belum tersedia', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/learning'),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final step = _steps[_currentStep];
    final isLast = _currentStep == _steps.length - 1;

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmed = await _showExitDialog(context);
        if (confirmed && context.mounted) {
          context.go('/learning/subject/${widget.subjectId}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Belajar'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/learning/subject/${widget.subjectId}'),
          ),
        ),
      body: Column(
        children: [
          // Progress dots
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentStep ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i <= _currentStep ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    step['title'] ?? '',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    step['content'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _completed ? null : _nextStep,
                child: Text(isLast ? 'Selesai! 🎉' : 'Lanjut →'),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Keluar dari pelajaran?'),
            content: const Text('Progress-mu tidak akan tersimpan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Keluar'),
              ),
            ],
          ),
        ) ??
        false;
  }
