import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result of an AI-generated insight
class AiInsight {
  final String text;
  final String type; // 'ai_generated' | 'rule_based'
  final bool cached;

  const AiInsight({
    required this.text,
    required this.type,
    required this.cached,
  });

  bool get isAiGenerated => type == 'ai_generated';
}

/// Calls the `generate-child-insights` Supabase Edge Function
class AiInsightRepository {
  final SupabaseClient _client;

  AiInsightRepository(this._client);

  Future<AiInsight?> generateInsight(String childId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client.functions.invoke(
        'generate-child-insights',
        body: {'childId': childId},
        options: FunctionInvokeOptions(
          headers: {
            'Authorization': 'Bearer ${user.id}',
          },
        ),
      );

      if (response.data == null) return null;

      final data = response.data as Map<String, dynamic>;
      return AiInsight(
        text: data['text'] as String? ?? '',
        type: data['type'] as String? ?? 'rule_based',
        cached: data['cached'] as bool? ?? false,
      );
    } catch (e) {
      // Edge function failed — rule-based insights will handle fallback
      return null;
    }
  }
}

// Repository provider
final aiInsightRepositoryProvider = Provider<AiInsightRepository>((ref) {
  return AiInsightRepository(Supabase.instance.client);
});

// Per-child AI insight — fetches once, cached by the edge function for the day
final aiInsightProvider =
    FutureProvider.family<AiInsight?, String>((ref, childId) async {
  final repo = ref.read(aiInsightRepositoryProvider);
  return repo.generateInsight(childId);
});
