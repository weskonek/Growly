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

  Stream<Map<String, dynamic>> watchTable(String table, String childId) {
    return _supabase
        .channel('table-changes-$table')
        .onPostgresChanges(
          schema: 'public',
          table: table,
          filter: PostgresChangeFilter(
            type: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            columns: ['*'],
          ),
          event: PostgresChangeEvent.all,
        )
        .map((change) => change.newRecord as Map<String, dynamic>);
  }
}