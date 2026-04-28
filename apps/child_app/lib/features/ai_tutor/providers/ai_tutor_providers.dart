import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/env.dart';
import '../../launcher/providers/launcher_providers.dart' as launcher;

/// Chat message model
class ChatMessage {
  final String id;
  final String content;
  final bool isAI;
  final DateTime timestamp;
  final String? mode;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isAI,
    required this.timestamp,
    this.mode,
  });
}

/// AI Tutor state
class AiTutorState {
  final String? sessionId;
  final List<ChatMessage> messages;
  final bool isLoading;

  const AiTutorState({
    this.sessionId,
    this.messages = const [],
    this.isLoading = false,
  });

  AiTutorState copyWith({
    String? sessionId,
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return AiTutorState(
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// AI Tutor notifier
class AiTutorNotifier extends AsyncNotifier<AiTutorState> {
  late final Dio _dio;

  @override
  Future<AiTutorState> build() async {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));
    return const AiTutorState();
  }

  Future<void> sendMessage(String text, {String mode = 'general'}) async {
    final currentState = state.valueOrNull ?? const AiTutorState();

    // Get child from launcher currentChildProvider
    final child = await ref.read(launcher.currentChildProvider.future);
    if (child == null) return;

    // Add user message immediately
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isAI: false,
      timestamp: DateTime.now(),
    );

    state = AsyncData(currentState.copyWith(
      messages: [...currentState.messages, userMessage],
      isLoading: true,
    ));

    try {
      // Call Supabase Edge Function ai-tutor
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;
      final supabaseUrl = AppEnv.supabaseUrl;
      final anonKey = AppEnv.supabaseAnonKey;

      final response = await _dio.post(
        '$supabaseUrl/functions/v1/ai-tutor',
        data: {
          'childId': child.id,
          'question': text,
          'mode': mode,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session?.accessToken ?? anonKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      final aiContent = response.data['content'] as String;
      final metadata = response.data['metadata'] as Map<String, dynamic>?;

      final aiMessage = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}ai',
        content: aiContent,
        isAI: true,
        timestamp: DateTime.now(),
        mode: metadata?['type'] as String?,
      );

      state = AsyncData(currentState.copyWith(
        sessionId: metadata?['sessionId'] as String?,
        messages: [...state.value!.messages, aiMessage],
        isLoading: false,
      ));
    } on DioException catch (_) {
      final errorMessage = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}err',
        content: 'Maaf, Growly sedang confused nih. Coba lagi sebentar ya! 🔄',
        isAI: true,
        timestamp: DateTime.now(),
      );
      state = AsyncData(currentState.copyWith(
        messages: [...state.value!.messages, errorMessage],
        isLoading: false,
      ));
    }
  }

  void clearMessages() {
    state = const AsyncData(AiTutorState());
  }
}

final aiTutorProvider =
    AsyncNotifierProvider<AiTutorNotifier, AiTutorState>(() {
  return AiTutorNotifier();
});

/// Session history from ai_tutor_sessions table
final aiSessionHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final child = await ref.read(launcher.currentChildProvider.future);
  if (child == null) return [];

  final data = await Supabase.instance.client
      .from('ai_tutor_sessions')
      .select()
      .eq('child_id', child.id)
      .order('created_at', ascending: false)
      .limit(20);

  return List<Map<String, dynamic>>.from(data as List);
});