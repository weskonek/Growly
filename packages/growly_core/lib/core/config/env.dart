class Env {
  Env._();

  // Supabase - replace with actual values
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // AI Gateway (Edge Function URL)
  static const String aiGatewayUrl = 'YOUR_AI_GATEWAY_URL';

  // Environment
  static const bool isProduction = bool.fromEnvironment('IS_PRODUCTION', defaultValue: false);
  static const bool isDevelopment = !isProduction;

  // Feature flags
  static const bool enableDebugLogs = isDevelopment;
  static const bool enableAnalytics = isProduction;
}