import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app.dart';
import 'core/config/env.dart';

// Firebase removed — FCM not yet implemented.
// To enable: add firebase_core + firebase_messaging to pubspec.yaml,
// run flutterfire configure, and restore the imports below.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: GrowlyParentApp(),
    ),
  );
}