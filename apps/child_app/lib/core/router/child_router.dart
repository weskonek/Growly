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
class _VerifiedIdNotifier extends ChangeNotifier {
  _VerifiedIdNotifier(this._container) {
    _container.listen(verifiedChildIdProvider, (_, __) {
      notifyListeners();
    });
  }

  final ProviderContainer _container;
}

/// Shell route builder — wraps all post-PIN routes with bottom nav
Widget _shellBuilder(BuildContext context, GoRouterState state, Widget child) {
  return ChildShell(location: state.matchedLocation, child: child);
}

/// Router provider for child app with PIN gate + bottom navigation.
final childRouterProvider = Provider<GoRouter>((ref) {
  final container = ProviderContainer();
  ref.onDispose(container.dispose);

  return GoRouter(
    initialLocation: '/launcher',
    redirect: (context, state) {
      // Always allow /launcher
      if (state.matchedLocation == '/launcher') return null;

      // PIN gate: redirect to launcher if not verified
      final verifiedId = container.read(verifiedChildIdProvider);
      if (verifiedId == null) return '/launcher';

      return null;
    },
    refreshListenable: _VerifiedIdNotifier(container),
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
              GoRoute(
                path: 'profile',
                name: 'profile',
                builder: (context, state) => const ChildProfilePage(),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ChildProfilePage(),
          ),
        ],
      ),
    ],
  );
});