import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/app.dart';
import 'core/config/env.dart';
import 'core/services/fcm_service.dart';

// Background message handler must be top-level / module-level for Flutter.
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] Message: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );

  // Initialize Firebase for FCM push notifications.
  // The try/catch handles the case where google-services.json /
  // GoogleService-Info.plist are not yet generated (before flutterfire configure).
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('[Main] Firebase init skipped (not configured): $e');
  }

  // Register background message handler before any Firebase use.
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);

  // Initialize FCM: request permission + register device token.
  // Safe to call even when Firebase was not initialized.
  await initFcm();

  runApp(
    const ProviderScope(
      child: GrowlyParentApp(),
    ),
  );
}
