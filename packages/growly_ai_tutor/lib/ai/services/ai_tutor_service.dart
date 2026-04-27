import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart' show Env, ServerFailure;
import '../models/ai_response.dart';
import '../models/tutor_context.dart';
import '../prompts/prompt_templates.dart';

class AiTutorService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));
  final PromptTemplates _promptTemplates = PromptTemplates();

  Future<AiResponse> askQuestion({
    required String question,
    required TutorContext context,
    required String mode,
    List<String>? conversationHistory,
  }) async {
    // Build prompt
    final promptContext = PromptContext(
      childContext: context,
      mode: mode,
      language: 'id',
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
        childId: context.childId,
      );

      return AiResponse(
        content: response['content'] as String,
        type: mode,
        metadata: response['metadata'] as Map<String, dynamic>? ?? {},
      );
    } catch (e) {
      throw const ServerFailure(message: 'Gagal menghubungi AI tutor. Coba lagi nanti.');
    }
  }

  Future<Map<String, dynamic>> _callAiGateway({
    required String systemPrompt,
    required String userPrompt,
    required String mode,
    required String childId,
  }) async {
    final response = await _dio.post(
      '${Env.aiGatewayUrl}',
      data: {
        'childId': childId,
        'question': userPrompt,
        'mode': mode,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  bool validateInput(String input) {
    const blockedPatterns = ['violence', 'adult', 'gambling', 'drug'];
    final lowerInput = input.toLowerCase();
    for (final pattern in blockedPatterns) {
      if (lowerInput.contains(pattern)) {
        return false;
      }
    }
    return true;
  }

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

final aiTutorServiceProvider = Provider<AiTutorService>((ref) {
  return AiTutorService();
});