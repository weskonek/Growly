import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/children/presentation/pages/children_list_page.dart';
import '../../features/children/presentation/pages/add_child_page.dart';
import '../../features/children/presentation/pages/child_detail_page.dart';
import '../../features/parental_control/presentation/pages/parental_control_page.dart';
import '../../features/parental_control/presentation/pages/screen_time_page.dart';
import '../../features/parental_control/presentation/pages/app_lock_page.dart';
import '../../features/parental_control/presentation/pages/school_mode_page.dart';
import '../../features/parental_control/presentation/pages/safe_mode_page.dart';
import '../../features/parental_control/presentation/pages/location_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/subscription_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import 'package:growly_core/growly_core.dart' show authStateChangesProvider;

/// Router provider with auth redirect logic
final appRouterProvider = Provider<GoRouter>((ref) {
  // Use growly_core's AsyncNotifier version — has eager seed to prevent blank screen
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      // Guard: while auth state is still loading, show splash — never render dashboard unauthenticated
      if (authState.isLoading) return '/splash';
      // valueOrNull is guaranteed non-null here due to _AuthStateNotifier eager seed
      final isLoggedIn = authState.valueOrNull!.session != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == '/splash';

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/dashboard';
      if (isLoggedIn && isSplash) return '/dashboard';
      return null;
    },
    routes: [
      // Splash shown while auth state is being resolved
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      // Auth routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/children',
            name: 'children',
            builder: (context, state) => const ChildrenListPage(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-child',
                builder: (context, state) => const AddChildPage(),
              ),
              GoRoute(
                path: 'detail/:childId',
                name: 'child-detail',
                builder: (context, state) => ChildDetailPage(
                  childId: state.pathParameters['childId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/parental-control',
            name: 'parental-control',
            builder: (context, state) => const ParentalControlPage(),
            routes: [
              GoRoute(
                path: 'screen-time/:childId',
                name: 'screen-time',
                builder: (context, state) => ScreenTimePage(
                  childId: state.pathParameters['childId']!,
                ),
              ),
              GoRoute(
                path: 'app-lock/:childId',
                name: 'app-lock',
                builder: (context, state) => AppLockPage(
                  childId: state.pathParameters['childId']!,
                ),
              ),
              GoRoute(
                path: 'school-mode/:childId',
                name: 'school-mode',
                builder: (context, state) => SchoolModePage(
                  childId: state.pathParameters['childId']!,
                ),
              ),
              GoRoute(
                path: 'safe-mode/:childId',
                name: 'safe-mode',
                builder: (context, state) => SafeModePage(
                  childId: state.pathParameters['childId']!,
                ),
              ),
              GoRoute(
                path: 'location/:childId',
                name: 'location',
                builder: (context, state) => LocationPage(
                  childId: state.pathParameters['childId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'subscription',
                name: 'subscription',
                builder: (context, state) => const SubscriptionPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/children')) return 1;
    if (location.startsWith('/parental-control')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _locationToIndex(location),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.child_care_outlined), selectedIcon: Icon(Icons.child_care), label: 'Anak'),
          NavigationDestination(icon: Icon(Icons.security_outlined), selectedIcon: Icon(Icons.security), label: 'Kontrol'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0: GoRouter.of(context).go('/dashboard'); break;
            case 1: GoRouter.of(context).go('/children'); break;
            case 2: GoRouter.of(context).go('/parental-control'); break;
            case 3: GoRouter.of(context).go('/settings'); break;
          }
        },
      ),
    );
  }
}