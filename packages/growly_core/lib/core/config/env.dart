import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for Growly.
/// .env file is loaded once in app's main() via dotenv.load().
/// This class reads from the loaded dotenv values.

class Env {
  Env._();

  /// Supabase Configuration
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ??
      'https://scfgcegyvgkxntqmmerl.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjZmdjZWd5dmdreG50cW1tZXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyOTUwMDksImV4cCI6MjA5Mjg3MTAwOX0.BP7E05P1ARVSdLz_UH0BSlL9k309bOD_MipXFHbTQPY';

  /// AI Gateway (Edge Function URL for AI Tutor)
  static String get aiGatewayUrl {
    final base = dotenv.env['SUPABASE_URL'] ??
        'https://scfgcegyvgkxntqmmerl.supabase.co';
    return '$base/functions/v1/ai-tutor';
  }

  /// Environment flags
  static bool get isProduction {
    final val = dotenv.env['IS_PRODUCTION'];
    return val == 'true';
  }

  static bool get isDevelopment => !isProduction;

  /// Feature flags
  static bool get enableDebugLogs => isDevelopment;
  static bool get enableAnalytics => isProduction;
}
