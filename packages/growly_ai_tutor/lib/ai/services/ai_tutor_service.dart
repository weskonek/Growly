import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:growly_core/growly_core.dart';
import '../models/ai_response.dart';
import '../models/tutor_context.dart';
import '../prompts/prompt_templates.dart';

part 'ai_tutor_service.g.dart';

@riverpod
class AiTutorService extends _$AiTutorService {
  late final Dio _dio;
  late final PromptTemplates _promptTemplates;

  @override
  AiTutorService build() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
    _promptTemplates = PromptTemplates();
    return this;
  }

  Future<AiResponse> askQuestion({
    required String question,
    required TutorContext context,
    required String mode,
    List<String>? conversationHistory,
  }) async {
    // Check cache first
    final cacheKey = _generateCacheKey(question, context.childId, mode);
    final cached = HiveService.getCachedAiResponse(cacheKey);
    if (cached != null) {
      return AiResponse.fromJson(cached);
    }

    // Build prompt
    final promptContext = PromptContext(
      childContext: context,
      mode: mode,
      language: 'id', // Indonesian
      conversationHistory: conversationHistory ?? [],
    );
    final systemPrompt = _promptTemplates.buildSystemPrompt(promptContext);
    final userPrompt = _promptTemplates.buildUserPrompt(question, context);

    // Call Edge Function
    try {
      final response = await _callAiGateway(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        mode: mode,
      );

      final aiResponse = AiResponse(
        content: response['content'] as String,
        type: mode,
        metadata: response['metadata'] as Map<String, dynamic>? ?? {},
      );

      // Cache the response
      await HiveService.cacheAiResponse(cacheKey, aiResponse.toJson());

      // Log interaction
      await _logInteraction(question, response, context.childId, mode);

      return aiResponse;
    } catch (e) {
      throw Failure.server(message: 'Gagal menghubungi AI tutor. Coba lagi nanti.');
    }
  }

  Stream<String> streamQuestion({
    required String question,
    required TutorContext context,
    required String mode,
  }) async* {
    final systemPrompt = _promptTemplates.buildSystemPrompt(
      PromptContext(
        childContext: context,
        mode: mode,
        language: 'id',
      ),
    );

    try {
      final response = await _dio.post(
        '${Env.aiGatewayUrl}/ai-tutor/stream',
        data: {
          'question': question,
          'systemPrompt': systemPrompt,
          'mode': mode,
          'context': context.toJson(),
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      await for (final chunk in (response.data as ResponseBody).stream) {
        yield utf8.decode(chunk);
      }
    } catch (e) {
      throw Failure.server(message: 'Gagal menghubungi AI tutor.');
    }
  }

  Future<Map<String, dynamic>> _callAiGateway({
    required String systemPrompt,
    required String userPrompt,
    required String mode,
  }) async {
    final response = await _dio.post(
      '${Env.aiGatewayUrl}/ai-tutor',
      data: {
        'systemPrompt': systemPrompt,
        'userPrompt': userPrompt,
        'mode': mode,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  String _generateCacheKey(String question, String childId, String mode) {
    return '${childId}_${mode}_${question.hashCode}';
  }

  Future<void> _logInteraction(
    String question,
    Map<String, dynamic> response,
    String childId,
    String mode,
  ) async {
    // TODO: Log to Supabase for analytics
    // This would typically be done via the sync manager
  }

  // Safety check for user input
  bool validateInput(String input) {
    // Basic safety validation
    final blockedPatterns = [
      'violence',
      'adult',
      'gambling',
      'drug',
    ];

    final lowerInput = input.toLowerCase();
    for (final pattern in blockedPatterns) {
      if (lowerInput.contains(pattern)) {
        return false;
      }
    }
    return true;
  }

  // Generate a story with comprehension questions
  Future<AiResponse> generateStory({
    required TutorContext context,
    required String topic,
    String? startingPoint,
  }) async {
    final prompt = _promptTemplates.buildStoryPrompt(
      context: context,
      topic: topic,
      startingPoint: startingPoint,
    );

    return askQuestion(
      question: prompt,
      context: context,
      mode: 'story',
    );
  }

  // Generate math problem with adaptive difficulty
  Future<AiResponse> generateMathProblem({
    required TutorContext context,
    required String difficulty,
    String? topic,
  }) async {
    final prompt = _promptTemplates.buildMathPrompt(
      context: context,
      difficulty: difficulty,
      topic: topic,
    );

    return askQuestion(
      question: prompt,
      context: context,
      mode: 'math',
    );
  }

  // Generate hint for homework
  Future<AiResponse> generateHint({
    required TutorContext context,
    required String question,
    int hintLevel = 1,
  }) async {
    final prompt = _promptTemplates.buildHintPrompt(
      context: context,
      question: question,
      hintLevel: hintLevel,
    );

    return askQuestion(
      question: prompt,
      context: context,
      mode: 'hint',
    );
  }
}