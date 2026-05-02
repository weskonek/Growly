import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Syncs app restriction rules from Supabase → device SharedPrefs
/// so that GrowlyAccessibilityService can enforce them.
///
/// The enforcement loop:
/// Parent locks app → Supabase app_restrictions INSERT/UPDATE
///   → Realtime push → ParentalControlSyncService._syncRestrictionsToDevice()
///   → MethodChannel updateRestrictions → SharedPrefs["locked_apps"]
///   → GrowlyAccessibilityService reads SharedPrefs → app is blocked ✅
class ParentalControlSyncService {
  static const _channel = MethodChannel('com.growly/android_parental_control');

  final SupabaseClient _supabase;
  RealtimeChannel? _realtimeChannel;
  RealtimeChannel? _scheduleChannel;
  String? _currentChildId;

  ParentalControlSyncService() : _supabase = Supabase.instance.client;

  /// Subscribe to Supabase Realtime and push current restrictions to device.
  Future<void> startSync(String childId) async {
    _currentChildId = childId;
    // 1. Immediate sync of current state
    await _syncRestrictionsToDevice(childId);
    await _syncScheduleToDevice(childId);
    // 2. Subscribe to live changes
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = _supabase
        .channel('restrictions-sync-$childId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'app_restrictions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'child_id',
            value: childId,
          ),
          callback: (_) => _syncRestrictionsToDevice(childId),
        )
        .subscribe();

    _scheduleChannel?.unsubscribe();
    _scheduleChannel = _supabase
        .channel('schedule-sync-$childId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'schedules',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'child_id',
            value: childId,
          ),
          callback: (_) => _syncScheduleToDevice(childId),
        )
        .subscribe();
  }

  /// Stop listening and cancel sync.
  void stopSync() {
    _realtimeChannel?.unsubscribe();
    _scheduleChannel?.unsubscribe();
    _realtimeChannel = null;
    _scheduleChannel = null;
    _currentChildId = null;
  }

  /// Read all restrictions from Supabase and push to native via updateRestrictions.
  Future<void> _syncRestrictionsToDevice(String childId) async {
    try {
      final rows = await _supabase
          .from('app_restrictions')
          .select('app_package, is_allowed')
          .eq('child_id', childId);

      final locked = <String>[];
      final allowed = <String>[];

      for (final row in rows) {
        final pkg = row['app_package'] as String;
        final isAllowed = row['is_allowed'] as bool? ?? false;
        if (isAllowed) {
          allowed.add(pkg);
        } else {
          locked.add(pkg);
        }
      }

      // Push all at once via updateRestrictions
      await _channel.invokeMethod('updateRestrictions', {
        'lockedApps': locked,
        'allowedApps': allowed,
        'screenTimeLimit': 0,
        'scheduleStart': '',
        'scheduleEnd': '',
        'scheduleMode': '',
      });
    } catch (e) {
      // Silent failure — enforcement will use last known state from SharedPrefs
    }
  }

  /// Read active schedule and push to native.
  Future<void> _syncScheduleToDevice(String childId) async {
    try {
      final now = DateTime.now();
      final dayOfWeek = now.weekday; // 1=Mon ... 7=Sun

      final rows = await _supabase
          .from('schedules')
          .select('start_time, end_time, mode, is_enabled')
          .eq('child_id', childId)
          .eq('is_enabled', true)
          .eq('day_of_week', dayOfWeek);

      if ((rows as List).isEmpty) return;

      final schedule = rows.first;
      final startTime = schedule['start_time']?.toString() ?? '';
      final endTime = schedule['end_time']?.toString() ?? '';
      final mode = schedule['mode']?.toString() ?? '';

      // Get current screen time limit from screen_time_rules
      final stRows = await _supabase
          .from('screen_time_rules')
          .select('daily_limit_minutes')
          .eq('child_id', childId)
          .maybeSingle();

      final limitMinutes = (stRows?['daily_limit_minutes'] as int?) ?? 0;

      // Also get locked apps to push with schedule
      final restrictionRows = await _supabase
          .from('app_restrictions')
          .select('app_package, is_allowed')
          .eq('child_id', childId);

      final locked = <String>[];
      final allowed = <String>[];
      for (final row in restrictionRows) {
        final pkg = row['app_package'] as String;
        if (row['is_allowed'] == true) {
          allowed.add(pkg);
        } else {
          locked.add(pkg);
        }
      }

      await _channel.invokeMethod('updateRestrictions', {
        'lockedApps': locked,
        'allowedApps': allowed,
        'screenTimeLimit': limitMinutes,
        'scheduleStart': startTime,
        'scheduleEnd': endTime,
        'scheduleMode': mode,
      });
    } catch (e) {
      // Silent failure
    }
  }

  /// Force a one-shot sync (useful after permission changes).
  Future<void> forceSync() async {
    if (_currentChildId != null) {
      await _syncRestrictionsToDevice(_currentChildId!);
      await _syncScheduleToDevice(_currentChildId!);
    }
  }
}
