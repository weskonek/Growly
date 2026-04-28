import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key';

  static String get aiGatewayUrl =>
      dotenv.env['AI_GATEWAY_URL'] ??
      'https://your-project.supabase.co/functions/v1/ai-tutor';
}
