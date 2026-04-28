/// Environment configuration for Growly.
/// IMPORTANT: In production, use environment variables or CI/CD secrets.
/// Do NOT commit real API keys to source control.

class Env {
  Env._();

  /// Supabase Configuration
  static String get supabaseUrl {
    return const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://scfgcegyvgkxntqmmerl.supabase.co',
    );
  }

  static String get supabaseAnonKey {
    return const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjZmdjZWd5dmdreG50cW1tZXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyOTUwMDksImV4cCI6MjA5Mjg3MTAwOX0.BP7E05P1ARVSdLz_UH0BSlL9k309bOD_MipXFHbTQPY',
    );
  }

  /// AI Gateway (Edge Function URL for AI Tutor)
  static String get aiGatewayUrl {
    return '$supabaseUrl/functions/v1/ai-tutor';
  }

  /// Environment flags
  static bool get isProduction {
    return const bool.fromEnvironment('IS_PRODUCTION', defaultValue: false);
  }

  static bool get isDevelopment => !isProduction;

  /// Feature flags
  static bool get enableDebugLogs => isDevelopment;
  static bool get enableAnalytics => isProduction;
}
