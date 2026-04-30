import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app.dart';
import 'core/config/env.dart';
import 'core/services/fcm_service.dart' show initFcm, fcmBackgroundHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );

  // Initialize Firebase + FCM
  try {
    await Firebase.initializeApp();
    await initFcm();

    // Register background handler for FCM messages
    FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
  } catch (e) {
    debugPrint('[main] Firebase/FCM init skipped: $e');
  }

  runApp(
    const ProviderScope(
      child: GrowlyParentApp(),
    ),
  );
}
