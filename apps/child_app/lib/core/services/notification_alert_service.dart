import 'package:supabase_flutter/supabase_flutter.dart';

enum AlertEvent {
  accessibilityRevoked,
  usageStatsRevoked,
  screenTimeExhausted,
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
    if (_isThrottled(event)) return;

    final (title, body) = _eventLabels(event);
    final type = _eventType(event);

    final resp = await _supabase.from('notifications').insert({
      'parent_id': parentId,
      'child_id': childId,
      'title': title,
      'body': body,
      'type': type,
      'is_read': false,
    }).select('id').single();

    final notificationId = resp['id'] as String;

    try {
      await _supabase.functions.invoke('notifications', body: {
        'notification_id': notificationId,
        'parent_id': parentId,
        'child_id': childId,
        'title': title,
        'body': body,
        'type': type,
      });
    } catch (_) {
      // Edge function failure is non-fatal — notification is in DB
    }

    _markSent(event);
  }

  (String, String) _eventLabels(AlertEvent event) {
    switch (event) {
      case AlertEvent.accessibilityRevoked:
        return ('⚠️ Proteksi Dinonaktifkan',
            'Izin aksesibilitas Growly telah dinonaktifkan di perangkat ini.');
      case AlertEvent.usageStatsRevoked:
        return ('⚠️ Akses Stats Dimatikan',
            'Izin Usage Stats telah dicabut. Screen time tidak bisa dipantau.');
      case AlertEvent.screenTimeExhausted:
        return ('⏰ Waktu Layar Habis',
            'Anak telah menghabiskan batas waktu layar hari ini.');
    }
  }

  String _eventType(AlertEvent event) {
    switch (event) {
      case AlertEvent.accessibilityRevoked:
      case AlertEvent.usageStatsRevoked:
        return 'alert';
      case AlertEvent.screenTimeExhausted:
        return 'screen_time_alert';
    }
  }
}