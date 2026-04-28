import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/remote/supabase_service.dart';
import '../../shared/services/sync_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.client;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SyncService(client);
});
