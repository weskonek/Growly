import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'services/fcm_service_stub.dart' show pendingDeepLinkProvider;
import 'theme/app_theme.dart';

class GrowlyParentApp extends ConsumerWidget {
  const GrowlyParentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Growly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

/// Computes the initial location by resolving both auth state and onboarding
/// completion, giving new users the onboarding wizard and returning users the
/// dashboard on cold start.
Future<String> resolveInitialLocation(WidgetRef ref) async {
  // FCM deep link takes priority
  final deepLink = ref.read(pendingDeepLinkProvider);
  if (deepLink != null) return deepLink;

  // Otherwise resolve auth + onboarding
  final onb = await ref.read(initialLocationProvider.future);
  return onb;
}
