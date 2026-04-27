import 'dart:async';

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
    final controller = StreamController<Map<String, dynamic>>.broadcast();

    _supabase
        .channel('table-changes-$table-$childId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'child_id',
            value: childId,
          ),
          callback: (payload) {
            controller.add(payload.newRecord);
          },
        )
        .subscribe();

    controller.onCancel = () {
      _supabase.removeChannel(_supabase.channel('table-changes-$table-$childId'));
    };

    return controller.stream;
  }
}