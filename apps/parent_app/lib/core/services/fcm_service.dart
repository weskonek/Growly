import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider that holds the pending deep link from a FCM notification.
/// Set when app was opened from a terminated state via notification tap,
/// or when foreground notification tap occurs.
final pendingDeepLinkProvider = StateProvider<String?>((ref) => null);

/// Init FCM: request permission, get/save token, subscribe to topic.
Future<String?> initFcm() async {
  try {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      return null;
    }

    await messaging.subscribeToTopic('growly');

    final token = await messaging.getToken();
    if (token != null) {
      await _saveToken(token);
    }

    messaging.onTokenRefresh.listen(_saveToken);

    return token;
  } catch (e) {
    debugPrint('[FCM] init failed: $e');
    return null;
  }
}

Future<void> _saveToken(String token) async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await Supabase.instance.client.from('parent_profiles').update({
      'fcm_token': token,
      'fcm_token_updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', user.id);
  } catch (e) {
    debugPrint('[FCM] Failed to save token: $e');
  }
}

/// Returns the deep-link path from notification data, or null.
String? _deepLinkFromData(Map<String, dynamic> data) {
  return data['deep_link'] as String?;
}

/// Background message handler — set as onBackgroundMessage in main.dart
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] title: ${message.notification?.title}');
  // Persist to DB if needed (background handler scope is limited)
}

/// Sets up foreground + background->foreground notification tap handlers.
/// Call this in main() AFTER Firebase.initializeApp().
void setupFcmNavigation(WidgetRef ref) {
  // 1. Handle tap when app was in BACKGROUND (already running)
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final deepLink = _deepLinkFromData(message.data);
    if (deepLink != null) {
      ref.read(pendingDeepLinkProvider.notifier).state = deepLink;
    }
  });

  // 2. Handle tap when app was KILLED — check initial message
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      final deepLink = _deepLinkFromData(message.data);
      if (deepLink != null) {
        ref.read(pendingDeepLinkProvider.notifier).state = deepLink;
      }
    }
  });
}