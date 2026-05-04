import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Uploads screen time data from Android UsageStats to Supabase.
/// Called periodically (every 15 min) from child app lifecycle.
class ScreenTimeUploadService {
  static const _channel = MethodChannel('com.growly/android_parental_control');

  final SupabaseClient _supabase;
  Timer? _uploadTimer;

  ScreenTimeUploadService() : _supabase = Supabase.instance.client;

  /// Start periodic upload every 15 minutes.
  void startPeriodicUpload(String childId) {
    _uploadTimer?.cancel();
    // Immediate first upload
    _uploadScreenTime(childId);
    // Then every 15 minutes
    _uploadTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _uploadScreenTime(childId),
    );
  }

  void stopPeriodicUpload() {
    _uploadTimer?.cancel();
    _uploadTimer = null;
  }

  Future<void> _uploadScreenTime(String childId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startMs = startOfDay.millisecondsSinceEpoch;
    final endMs = now.millisecondsSinceEpoch;

    try {
      // Call native MethodChannel that reads Android UsageStats
      final Map<dynamic, dynamic>? appUsage = await _channel.invokeMapMethod(
        'getScreenTimeByApp',
        {'start': startMs, 'end': endMs},
      );

      if (appUsage == null || appUsage.isEmpty) return;

      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Build upsert records — duration already in seconds from native, convert to minutes
      final records = <Map<String, dynamic>>[];
      for (final entry in appUsage.entries) {
        final packageName = entry.key as String;
        final durationSeconds = entry.value as int;
        if (durationSeconds <= 0) continue;
        records.add({
          'child_id': childId,
          'app_package': packageName,
          'duration_minutes': durationSeconds ~/ 60,
          'date': today,
        });
      }

      if (records.isEmpty) return;

      // Upsert — unique constraint (child_id, app_package, date) handles conflicts
      await _supabase.from('screen_time_records').upsert(
            records,
            onConflict: 'child_id,app_package,date',
          );
    } catch (e, stackTrace) {
      debugPrint('[ScreenTime] Upload failed: $e');
      debugPrint('[ScreenTime] Stack: $stackTrace');
      // Silent failure for production, but visible during development
    }
  }

  /// One-shot upload (call when app closes or screen locks)
  Future<void> uploadNow(String childId) async {
    await _uploadScreenTime(childId);
  }

  void dispose() {
    _uploadTimer?.cancel();
    _uploadTimer = null;
  }
}
