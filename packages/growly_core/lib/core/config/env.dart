/// Environment configuration for Growly.
/// IMPORTANT: In production, use environment variables or CI/CD secrets.
/// Do NOT commit real API keys to source control.

class Env {
  Env._();

  /// Supabase Configuration
  /// Set via environment variables: SUPABASE_URL, SUPABASE_ANON_KEY
  static String get supabaseUrl {
    return const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://your-project.supabase.co',
    );
  }

  static String get supabaseAnonKey {
    return const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'YOUR_ANON_KEY_HERE',
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