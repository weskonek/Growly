class AppEnv {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://your-project.supabase.co');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'your-anon-key');
  static const aiGatewayUrl = String.fromEnvironment('AI_GATEWAY_URL', defaultValue: 'https://your-project.supabase.co/functions/v1/ai-tutor');
}
