import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/launcher/presentation/pages/child_launcher_page.dart';
import '../../features/home/presentation/pages/child_home_page.dart';
import '../../features/learning/presentation/pages/learning_hub_page.dart';
import '../../features/learning/presentation/pages/subject_detail_page.dart';
import '../../features/learning/presentation/pages/lesson_page.dart';
import '../../features/ai_tutor/presentation/pages/ai_tutor_page.dart';
import '../../features/rewards/presentation/pages/rewards_page.dart';
import '../../features/store/presentation/pages/growly_store_page.dart';
import '../../features/profile/presentation/pages/child_profile_page.dart';
import '../widgets/child_shell.dart';

/// Tracks whether the child has been verified via PIN gate
final verifiedChildIdProvider = StateProvider<String?>((ref) => null);

/// Bridges Riverpod StateProvider to go_router's refreshListenable.
/// FIX: Use ref.container from the main tree, NOT a new ProviderContainer.
class _VerifiedIdNotifier extends ChangeNotifier {
  _VerifiedIdNotifier(Ref ref) {
    ref.listen(verifiedChildIdProvider, (_, __) {
      notifyListeners();
    });
  }
}

/// Shell route builder — wraps all post-PIN routes with bottom nav
Widget _shellBuilder(BuildContext context, GoRouterState state, Widget child) {
  return ChildShell(location: state.matchedLocation, child: child);
}

/// Router provider for child app with PIN gate + bottom navigation.
final childRouterProvider = Provider<GoRouter>((ref) {
  // FIX Bug A: use ref directly — connected to the widget tree
  final notifier = _VerifiedIdNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/launcher',
    redirect: (context, state) {
      if (state.matchedLocation == '/launcher') return null;

      // FIX Bug A: read from the correct ref (widget tree), not a separate container
      final verifiedId = ref.read(verifiedChildIdProvider);
      if (verifiedId == null) return '/launcher';

      return null;
    },
    refreshListenable: notifier,
    routes: [
      // PIN gate — outside shell
      GoRoute(
        path: '/launcher',
        name: 'launcher',
        builder: (context, state) => const ChildLauncherPage(),
      ),
      // All post-verification routes wrapped in ShellRoute with bottom nav
      ShellRoute(
        builder: _shellBuilder,
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const ChildHomePage(),
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
            routes: [
              GoRoute(
                path: 'store',
                name: 'store',
                builder: (context, state) => const GrowlyStorePage(),
              ),
              // FIX Bug B removed: sub-route 'profile' under rewards no longer exists
              // Only /profile top-level route exists below
            ],
          ),
          GoRoute(
            path: '/profile',
            name: 'profile', // ✅ only one route with this name
            builder: (context, state) => const ChildProfilePage(),
          ),
        ],
      ),
    ],
  );
});