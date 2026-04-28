import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:child_app/features/learning/providers/learning_providers.dart';

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
  final _steps = const [
    _LessonStep(
      title: 'Yuk, mulai belajar!',
      content: 'Hari ini kita akan belajar hal baru yang seru. Perhatikan baik-baik ya!',
    ),
    _LessonStep(
      title: 'Contoh Soal',
      content: 'Sekarang coba lihat contoh ini. Kalau bingung, tanya Growly AI ya!',
    ),
    _LessonStep(
      title: 'Waktunya Latihan!',
      content: 'Sekarang kamu coba sendiri ya. Jangan lupa belajar dari kesalahan!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Start session when entering lesson
    ref.read(learningSessionProvider.notifier).startSession(widget.subjectId);
  }

  @override
  void dispose() {
    // End session when leaving lesson
    final duration = DateTime.now().difference(_sessionStart);
    ref.read(learningSessionProvider.notifier).endSession(
          durationMinutes: duration.inMinutes,
        );
    super.dispose();
  }

  final _sessionStart = DateTime.now();

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _completeLesson();
    }
  }

  void _completeLesson() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hebat! Kamu sudah selesai belajar! 🎉')),
    );
    context.go('/learning');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final step = _steps[_currentStep];
    final isLast = _currentStep == _steps.length - 1;

    return Scaffold(
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
                    step.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    step.content,
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
                onPressed: _nextStep,
                child: Text(isLast ? 'Selesai! 🎉' : 'Lanjut →'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonStep {
  final String title;
  final String content;
  const _LessonStep({required this.title, required this.content});
}
