import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'local/hive_service.dart';

class SyncManager {
  final SupabaseClient _supabase;
  bool _isSyncing = false;

  SyncManager(this._supabase);

  Future<void> syncOfflineData() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final queue = HiveService.getOfflineQueue();
      for (int i = 0; i < queue.length; i++) {
        final item = queue[i];
        final operation = item['operation'] as String;
        final data = item['data'] as Map<String, dynamic>;

        try {
          await _processOperation(operation, data);
          await HiveService.removeFromOfflineQueue(i);
        } catch (e) {
          // Keep in queue for retry
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processOperation(String operation, Map<String, dynamic> data) async {
    final table = data['table'] as String;
    final record = data['record'] as Map<String, dynamic>;

    switch (operation) {
      case 'insert':
        await _supabase.from(table).insert(record);
        break;
      case 'update':
        final id = record['id'];
        record.remove('id');
        await _supabase.from(table).update(record).eq('id', id);
        break;
      case 'delete':
        await _supabase.from(table).delete().eq('id', record['id']);
        break;
    }
  }

  Future<void> pushToSupabase(String table, Map<String, dynamic> record, String operation) async {
    try {
      await _processOperation(operation, {'table': table, 'record': record});
    } catch (e) {
      // Offline - add to queue
      await HiveService.addToOfflineQueue(operation, {'table': table, 'record': record});
    }
  }

  Stream<Map<String, dynamic>> watchTable(String table, String childId) {
    return _supabase
        .channel('sync-$table-$childId')
        .onPostgresChanges(
          schema: 'public',
          table: table,
          filter: Filter.eq('child_id', childId),
          event: PostgresChangeEvent.all,
        )
        .map((change) => change.newRecord as Map<String, dynamic>);
  }
}