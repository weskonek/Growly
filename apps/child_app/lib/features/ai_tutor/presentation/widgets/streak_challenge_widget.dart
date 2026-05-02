import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Providers for streak tracking — persist in-memory per session
final _streakCountProvider = StateProvider<int>((ref) => 0);
final _streakActiveProvider = StateProvider<bool>((ref) => false);

class StreakChallengeWidget extends ConsumerWidget {
  final int correctAnswers;
  final VoidCallback? onDismiss;
  final void Function(String answer)? onSubmitAnswer;

  const StreakChallengeWidget({
    super.key,
    required this.correctAnswers,
    this.onDismiss,
    this.onSubmitAnswer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(_streakCountProvider);
    final isActive = ref.watch(_streakActiveProvider);

    // Show after 3 consecutive correct answers
    if (correctAnswers < 3 && !isActive) {
      return const SizedBox.shrink();
    }

    // Activate streak mode
    if (correctAnswers >= 3 && !isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(_streakActiveProvider.notifier).state = true;
        ref.read(_streakCountProvider.notifier).state = correctAnswers;
      });
      return const SizedBox.shrink();
    }

    final isHighStreak = streak >= 5;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isHighStreak
                ? [Colors.purple.shade600, Colors.orange.shade600]
                : [Colors.blue.shade600, Colors.cyan.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isHighStreak ? Colors.purple : Colors.blue)
                  .withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isHighStreak) ...[
                      const Text('🔥', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      isHighStreak ? 'STREAK MODE!' : 'STREAK!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (isHighStreak) ...[
                      const SizedBox(width: 8),
                      const Text('🔥', style: TextStyle(fontSize: 32)),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = i < streak;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: filled ? 1 : 0),
                      duration: Duration(milliseconds: 300 + (i * 100)),
                      builder: (context, val, _) {
                        return Transform.scale(
                          scale: 0.5 + (0.5 * val),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: filled
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              boxShadow: filled
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: filled
                                      ? (isHighStreak
                                          ? Colors.purple.shade700
                                          : Colors.blue.shade700)
                                      : Colors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  isHighStreak
                      ? '🔥 $streak STREAK! AMAN BOMBER! 🔥'
                      : 'Benar $streak kali berturut-turut!',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (isHighStreak) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '✨ STREAK SPESIAL ✨',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (onSubmitAnswer != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StreakButton(
                        label: '✅ Benar',
                        color: Colors.green,
                        onTap: () => onSubmitAnswer!('correct'),
                      ),
                      const SizedBox(width: 12),
                      _StreakButton(
                        label: '❌ Salah',
                        color: Colors.red,
                        onTap: () => onSubmitAnswer!('wrong'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StreakButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StreakButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

/// Resets streak count — call this when the session changes or user starts new topic
void resetStreak(BuildContext context) {
  // Access through a global key or pass ref
}

/// Convenience widget to wrap AI tutor and inject streak tracking
class StreakWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final String childId;

  const StreakWrapper({
    super.key,
    required this.child,
    required this.childId,
  });

  @override
  ConsumerState<StreakWrapper> createState() => _StreakWrapperState();
}

class _StreakWrapperState extends ConsumerState<StreakWrapper> {
  int _streak = 0;
  bool _showStreak = false;

  void _handleAnswer(bool correct) {
    setState(() {
      if (correct) {
        _streak++;
        if (_streak >= 3) _showStreak = true;
      } else {
        _streak = 0;
        _showStreak = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showStreak)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: StreakChallengeWidget(
              correctAnswers: _streak,
              onSubmitAnswer: (answer) => _handleAnswer(answer == 'correct'),
            ),
          ),
      ],
    );
  }
}