import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/launcher/presentation/pages/child_launcher_page.dart';
import '../../features/learning/presentation/pages/learning_hub_page.dart';
import '../../features/ai_tutor/presentation/pages/ai_tutor_page.dart';
import '../../features/rewards/presentation/pages/rewards_page.dart';

part 'child_router.g.dart';

@riverpod
GoRouter childRouter(ChildRouterRef ref) {
  return GoRouter(
    initialLocation: '/launcher',
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
}
