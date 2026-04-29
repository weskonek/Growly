import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Syncs app restriction rules from Supabase → device SharedPrefs
/// so that GrowlyAccessibilityService can enforce them.
///
/// The enforcement loop:
/// Parent locks app → Supabase app_restrictions INSERT/UPDATE
///   → Realtime push → ParentalControlSyncService._syncRestrictionsToDevice()
///   → MethodChannel lockApp/unlockApp → SharedPrefs["locked_apps"]
///   → GrowlyAccessibilityService reads SharedPrefs → app is blocked ✅
class ParentalControlSyncService {
  static const _channel = MethodChannel('com.growly/android_parental_control');

  final SupabaseClient _supabase;
  RealtimeChannel? _realtimeChannel;
  String? _currentChildId;

  ParentalControlSyncService() : _supabase = Supabase.instance.client;

  /// Subscribe to Supabase Realtime and push current restrictions to device.
  Future<void> startSync(String childId) async {
    _currentChildId = childId;
    // 1. Immediate sync of current state
    await _syncRestrictionsToDevice(childId);
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
  }

  /// Stop listening and cancel sync.
  void stopSync() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
    _currentChildId = null;
  }

  /// Read all restrictions from Supabase and push lock/unlock to device.
  Future<void> _syncRestrictionsToDevice(String childId) async {
    try {
      final rows = await _supabase
          .from('app_restrictions')
          .select('app_package, is_allowed')
          .eq('child_id', childId);

      // Partition into locked (is_allowed = false) and allowed
      final locked = <String>{};
      final allowed = <String>{};

      for (final row in rows) {
        final pkg = row['app_package'] as String;
        final isAllowed = row['is_allowed'] as bool? ?? false;
        if (isAllowed) {
          allowed.add(pkg);
        } else {
          locked.add(pkg);
        }
      }

      // Push locked apps to native
      for (final pkg in locked) {
        await _channel.invokeMethod('lockApp', {'package': pkg});
      }

      // Push allowed apps to native (unblock if previously locked)
      for (final pkg in allowed) {
        await _channel.invokeMethod('unlockApp', {'package': pkg});
      }
    } catch (e) {
      // Silent failure — enforcement will use last known state from SharedPrefs
    }
  }

  /// Force a one-shot sync (useful after permission changes).
  Future<void> forceSync() async {
    if (_currentChildId != null) {
      await _syncRestrictionsToDevice(_currentChildId!);
    }
  }
}
