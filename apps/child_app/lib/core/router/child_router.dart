import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/launcher/presentation/pages/child_launcher_page.dart';
import '../../features/learning/presentation/pages/learning_hub_page.dart';
import '../../features/learning/presentation/pages/subject_detail_page.dart';
import '../../features/learning/presentation/pages/lesson_page.dart';
import '../../features/ai_tutor/presentation/pages/ai_tutor_page.dart';
import '../../features/rewards/presentation/pages/rewards_page.dart';

/// Tracks whether the child has been verified via PIN gate
final verifiedChildIdProvider = StateProvider<String?>((ref) => null);

/// Bridges Riverpod StateProvider to go_router's refreshListenable.
/// Router rebuilds redirect when verifiedChildIdProvider changes.
class _VerifiedIdNotifier extends ChangeNotifier {
  _VerifiedIdNotifier(this._ref) {
    _ref.listen(verifiedChildIdProvider, (_, __) {
      notifyListeners();
    });
  }

  final WidgetRef _ref;
}

/// Router provider for child app with PIN gate protection.
final childRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _VerifiedIdNotifier(ref);

  return GoRouter(
    initialLocation: '/launcher',
    redirect: (context, state) {
      if (state.matchedLocation == '/launcher') return null;

      final verifiedId = ref.read(verifiedChildIdProvider);
      if (verifiedId == null) return '/launcher';

      return null;
    },
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/launcher',
        name: 'launcher',
        builder: (context, state) => const ChildLauncherPage(),
      ),
      GoRoute(
        path: '/learning',
        name: 'learning',
        builder: (context, state) => const LearningHubPage(),
        routes: [
          GoRoute(
            path: 'subject/:subjectId',
            name: 'subject-detail',
            builder: (context, state) => SubjectDetailPage(
              subjectId: state.pathParameters['subjectId']!,
            ),
            routes: [
              GoRoute(
                path: 'lesson/:lessonId',
                name: 'lesson',
                builder: (context, state) => LessonPage(
                  subjectId: state.pathParameters['subjectId']!,
                  lessonId: state.pathParameters['lessonId']!,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/ai-tutor',
        name: 'ai-tutor',
        builder: (context, state) => const AiTutorPage(),
      ),
      GoRoute(
        path: '/rewards',
        name: 'rewards',
        builder: (context, state) => const RewardsPage(),
      ),
    ],
  );
});