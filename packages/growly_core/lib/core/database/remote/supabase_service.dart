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
      // Fallback: use Supabase.instance if SupabaseService.init() wasn't called
      // but Supabase.initialize() was called directly in app main()
      return Supabase.instance.client;
    }
    return _instance!;
  }
}