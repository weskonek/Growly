import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/env.dart';

class SupabaseService {
  static SupabaseClient? _instance;

  static Future<void> init() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    _instance = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_instance == null) {
      throw Exception('Supabase not initialized. Call SupabaseService.init() first.');
    }
    return _instance!;
  }
}