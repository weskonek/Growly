import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/child_router.dart';
import 'theme/child_theme.dart';

class GrowlyChildApp extends ConsumerWidget {
  const GrowlyChildApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(childRouterProvider);

    return MaterialApp.router(
      title: 'Growly',
      debugShowCheckedModeBanner: false,
      theme: ChildTheme.light,
      routerConfig: router,
    );
  }
}
