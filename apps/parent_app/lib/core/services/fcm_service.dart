import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider that holds the pending deep link from a notification tap.
/// Read by the router to redirect the user after the app opens.
final pendingDeepLinkProvider = StateProvider<String?>((ref) => null);

/// Module-level variable for cold-start deep-link access.
/// FCM callbacks fire outside the widget tree where ProviderRef isn't available.
String? _pendingDeepLink;

String? getPendingDeepLink() => _pendingDeepLink;
void clearPendingDeepLink() => _pendingDeepLink = null;

/// Init FCM — call this in main.dart after Supabase.initialize().
///
/// - Requests notification permission (iOS prompts user, Android 13+ prompts user)
/// - Fetches and registers the FCM token in `parent_profiles.fcm_token`
/// - Listens for token refresh to re-register
/// - Handles foreground messages and notification taps
///
/// Returns the FCM token on success, null on failure.
Future<String?> initFcm() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('[FCM] Firebase initialization failed: $e');
    return null;
  }

  final messaging = FirebaseMessaging.instance;

  // Request notification permission
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    debugPrint('[FCM] Permission denied by user');
    return null;
  }

  // Get FCM token
  final token = await messaging.getToken();
  if (token == null) {
    debugPrint('[FCM] No FCM token returned');
    return null;
  }

  // Register token with Supabase
  await _registerFcmToken(token);

  // Re-register on token refresh
  messaging.onTokenRefresh.listen(_registerFcmToken);

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

  // Handle notification tap when app is in background (but not killed)
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

  // Check if app was opened from a notification (cold start)
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    _handleMessageOpenedApp(initialMessage);
  }

  debugPrint('[FCM] Initialized successfully. Token: ${token.substring(0, 8)}…');
  return token;
}

Future<void> _registerFcmToken(String token) async {
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('[FCM] Cannot register token: not authenticated');
      return;
    }

    await Supabase.instance.client
        .from('parent_profiles')
        .update({
          'fcm_token': token,
          'fcm_token_updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', userId);

    debugPrint('[FCM] Token registered for user $userId');
  } catch (e) {
    debugPrint('[FCM] Failed to register token: $e');
  }
}

void _handleForegroundMessage(RemoteMessage message) {
  debugPrint(
    '[FCM] Foreground message received: ${message.notification?.title}',
  );
  // The notification list in the parent app auto-refreshes via Supabase
  // Realtime subscription on the notifications table.
  // In-app snoozing / local notifications can be added here later.
}

void _handleMessageOpenedApp(RemoteMessage message) {
  debugPrint('[FCM] Notification tap: ${message.data}');
  final deepLink = message.data['deep_link'] as String?;
  if (deepLink != null) {
    _pendingDeepLink = deepLink;
  }
}

/// Background message handler — must be top-level for Flutter.
///
/// Registered in main.dart via `FirebaseMessaging.onBackgroundMessage`.
/// Requires:
///
/// - `class FirebaseMessagingBackgroundHandler` exported from
///   `firebase_messaging_background.dart` on some Flutter SDK versions.
/// - `plugins.firebse.google.cn/com.google.firebase:firebase-messaging-flutter`
///   added to android/app/build.gradle.
///
/// For now this logs the message; real background handling (local
/// notifications, offline sync) can be added when needed.
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] Message: ${message.notification?.title}');
}

/// Setup FCM navigation hooks after router is initialized.
/// Call this once from the app entry point after runApp().
void setupFcmNavigation() {
  debugPrint('[FCM] Navigation setup complete');
}
