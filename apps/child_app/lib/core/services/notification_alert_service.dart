import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AlertEvent {
  accessibilityRevoked,
  usageStatsRevoked,
  screenTimeExhausted,
}

extension AlertEventX on AlertEvent {
  String get key {
    switch (this) {
      case AlertEvent.accessibilityRevoked:
        return 'accessibility_revoked';
      case AlertEvent.usageStatsRevoked:
        return 'usage_stats_revoked';
      case AlertEvent.screenTimeExhausted:
        return 'screen_time_exceeded';
    }
  }

  String get title {
    switch (this) {
      case AlertEvent.accessibilityRevoked:
        return '⚠️ Pengawasan Dinonaktifkan';
      case AlertEvent.usageStatsRevoked:
        return '⚠️ Izin Statistik Dicabut';
      case AlertEvent.screenTimeExhausted:
        return '⏰ Waktu Layar Habis';
    }
  }

  String bodyFor(String childName) {
    switch (this) {
      case AlertEvent.accessibilityRevoked:
        return '$childName telah menonaktifkan layanan pengawasan Growly. Kontrol orang tua mungkin tidak aktif.';
      case AlertEvent.usageStatsRevoked:
        return '$childName mencabut izin statistik penggunaan. Pemantauan aplikasi terganggu.';
      case AlertEvent.screenTimeExhausted:
        return 'Waktu layar harian $childName telah habis. Perangkat sekarang dibatasi.';
    }
  }
}

class NotificationAlertService {
  NotificationAlertService();

  final _supabase = Supabase.instance.client;

  static final Map<AlertEvent, DateTime> _sentLog = {};
  static const _throttleWindow = Duration(minutes: 15);

  bool _isThrottled(AlertEvent event) {
    final last = _sentLog[event];
    if (last == null) return false;
    return DateTime.now().difference(last) < _throttleWindow;
  }

  void _markSent(AlertEvent event) {
    _sentLog[event] = DateTime.now();
  }

  Future<void> sendAlert({
    required String childId,
    required String parentId,
    required AlertEvent event,
  }) async {
    if (_isThrottled(event)) {
      debugPrint('[Alert] Throttled: ${event.key}');
      return;
    }

    final childRow = await _supabase
        .from('child_profiles')
        .select('name')
        .eq('id', childId)
        .maybeSingle();

    final childName = (childRow?['name'] as String?) ?? 'Anak';
    final body = event.bodyFor(childName);

    final resp = await _supabase.from('notifications').insert({
      'parent_id': parentId,
      'child_id': childId,
      'title': event.title,
      'body': body,
      'type': event.key,
      'is_read': false,
    }).select('id').single();

    final notificationId = resp['id'] as String;

    try {
      await _supabase.functions.invoke('notifications', body: {
        'notification_id': notificationId,
        'parent_id': parentId,
        'child_id': childId,
        'title': event.title,
        'body': body,
        'type': event.key,
      });
    } catch (_) {
      // Non-fatal — notification is in DB
    }

    _markSent(event);
    debugPrint('[Alert] Sent: ${event.key} for child $childId → parent $parentId');
  }

  @visibleForTesting
  void resetThrottle(AlertEvent event) {
    _sentLog.remove(event);
  }
}
