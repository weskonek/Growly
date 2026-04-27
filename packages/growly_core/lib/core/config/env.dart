class Env {
  Env._();

  // Supabase
  static const String supabaseUrl = 'https://scfgcegyvgkxntqmmerl.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjZmdjZWd5dmdreG50cW1tZXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyOTUwMDksImV4cCI6MjA5Mjg3MTAwOX0.BP7E05P1ARVSdLz_UH0BSlL9k309bOD_MipXFHbTQPY';

  // AI Gateway (Edge Function URL)
  static const String aiGatewayUrl = 'https://scfgcegyvgkxntqmmerl.supabase.co/functions/v1/ai-tutor';

  // Environment
  static const bool isProduction = bool.fromEnvironment('IS_PRODUCTION', defaultValue: false);
  static const bool isDevelopment = !isProduction;

  // Feature flags
  static const bool enableDebugLogs = isDevelopment;
  static const bool enableAnalytics = isProduction;
}