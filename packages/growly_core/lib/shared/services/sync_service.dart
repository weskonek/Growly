import 'package:supabase_flutter/supabase_flutter.dart';

class SyncService {
  final SupabaseClient _supabase;

  SyncService(this._supabase);

  Future<void> pushChanges(Map<String, dynamic> data, String table) async {
    await _supabase.from(table).upsert(data);
  }

  Future<List<Map<String, dynamic>>> pullChanges(
    String table,
    DateTime since,
  ) async {
    final response = await _supabase
        .from(table)
        .select()
        .gt('updated_at', since.toIso8601String());
    return (response as List).cast<Map<String, dynamic>>();
  }

  RealtimeChannel watchTable(
    String table,
    String childId,
    void Function(Map<String, dynamic>) onChange,
  ) {
    return _supabase
        .channel('table-changes-$table-$childId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: (payload) {
            final record = payload.newRecord;
            if (record['child_id'] == childId) {
              onChange(record);
            }
          },
        );
  }
}