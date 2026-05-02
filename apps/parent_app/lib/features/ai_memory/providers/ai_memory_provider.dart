import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChildAiMemory {
  final String? nickname;
  final String? learningStyle;
  final List<String> interests;
  final Map<String, double> topicMastery;
  final List<Map<String, String>> breakthroughs;
  final String? lastMood;
  final String? lastAnalogyWorked;

  ChildAiMemory({
    this.nickname,
    this.learningStyle,
    this.interests = const [],
    this.topicMastery = const {},
    this.breakthroughs = const [],
    this.lastMood,
    this.lastAnalogyWorked,
  });

  factory ChildAiMemory.fromMap(Map<String, dynamic> m) {
    return ChildAiMemory(
      nickname: m['nickname'] as String?,
      learningStyle: m['learning_style'] as String?,
      interests: List<String>.from(m['interests'] ?? []),
      topicMastery: (m['topic_mastery'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
      breakthroughs: (m['breakthroughs'] as List?)
              ?.map((b) => Map<String, String>.from(b as Map))
              .toList() ??
          [],
      lastMood: m['last_mood'] as String?,
      lastAnalogyWorked: m['last_analogy_worked'] as String?,
    );
  }
}

final childAiMemoryProvider =
    FutureProvider.family<ChildAiMemory?, String>((ref, childId) async {
  final data = await Supabase.instance.client
      .from('child_ai_memory')
      .select()
      .eq('child_id', childId)
      .maybeSingle();

  if (data == null) return null;
  return ChildAiMemory.fromMap(data);
});

final aiMemoryProgressProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, childId) async {
  final memory = await ref.watch(childAiMemoryProvider(childId).future);
  final sessions = await Supabase.instance.client
      .from('ai_tutor_sessions')
      .select('mode, created_at')
      .eq('child_id', childId)
      .eq('flagged', false)
      .order('created_at', ascending: false)
      .limit(50);

  final sessionList = sessions as List;
  final totalSessions = sessionList.length;
  final modes = sessionList.map((s) => s['mode'] as String? ?? 'general').toList();

  final mathSessions =
      modes.where((m) => m == 'math' || m == 'homework').length;
  final storySessions = modes.where((m) => m == 'story').length;
  final generalSessions = modes.where((m) => m == 'general').length;

  final thisWeek = DateTime.now().difference(
        DateTime.parse(sessionList.lastOrNull?['created_at'] ?? DateTime.now().toIso8601String())
      ).inDays <= 7;

  return {
    'totalSessions': totalSessions,
    'mathSessions': mathSessions,
    'storySessions': storySessions,
    'generalSessions': generalSessions,
    'thisWeekActive': thisWeek,
    'memory': memory,
  };
});