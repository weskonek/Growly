import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_response.freezed.dart';
part 'ai_response.g.dart';

@freezed
class AiResponse with _$AiResponse {
  const factory AiResponse({
    required String content,
    required String type, // 'story', 'math', 'general', 'hint'
    String? audioUrl,
    @Default({}) Map<String, dynamic> metadata,
  }) = _AiResponse;

  factory AiResponse.fromJson(Map<String, dynamic> json) =>
      _$AiResponseFromJson(json);
}

@freezed
class AiMessage with _$AiMessage {
  const factory AiMessage({
    required String id,
    required String role, // 'user' or 'assistant'
    required String content,
    DateTime? timestamp,
    String? type,
  }) = _AiMessage;

  factory AiMessage.fromJson(Map<String, dynamic> json) =>
      _$AiMessageFromJson(json);
}

@freezed
class AiSession with _$AiSession {
  const factory AiSession({
    required String id,
    required String childId,
    required String mode, // 'story', 'math', 'homework'
    required DateTime startedAt,
    DateTime? endedAt,
    @Default([]) List<AiMessage> messages,
    @Default({}) Map<String, dynamic> context,
  }) = _AiSession;

  factory AiSession.fromJson(Map<String, dynamic> json) =>
      _$AiSessionFromJson(json);
}

enum AiTutorMode {
  storyteller,
  mathBuddy,
  homeworkGuide,
  general,
}

extension AiTutorModeX on AiTutorMode {
  String get displayName {
    switch (this) {
      case AiTutorMode.storyteller:
        return 'Cerita';
      case AiTutorMode.mathBuddy:
        return 'Matematika';
      case AiTutorMode.homeworkGuide:
        return 'PR';
      case AiTutorMode.general:
        return 'Umum';
    }
  }

  String get emoji {
    switch (this) {
      case AiTutorMode.storyteller:
        return '📖';
      case AiTutorMode.mathBuddy:
        return '🔢';
      case AiTutorMode.homeworkGuide:
        return '📝';
      case AiTutorMode.general:
        return '🤖';
    }
  }
}