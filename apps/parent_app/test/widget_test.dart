import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parent_app/core/app.dart';
import 'package:parent_app/core/router/app_router.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('GrowlyParentApp initializes correctly', (WidgetTester tester) async {
    // Override the app router to avoid Supabase dependency in testing
    final mockRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Text('Mock Home'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(mockRouter),
        ],
        child: const GrowlyParentApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Mock Home'), findsOneWidget);
  });
}