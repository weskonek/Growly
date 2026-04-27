import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_progress.freezed.dart';
part 'learning_progress.g.dart';

@freezed
class LearningProgress with _$LearningProgress {
  const factory LearningProgress({
    required String id,
    required String childId,
    required String subject,
    required String topic,
    @Default(0) int score,
    @Default(false) bool completed,
    DateTime? completedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? sessionId,
    @Default({}) Map<String, dynamic> metadata,
  }) = _LearningProgress;

  factory LearningProgress.fromJson(Map<String, dynamic> json) =>
      _$LearningProgressFromJson(json);
}

@freezed
class LearningSession with _$LearningSession {
  const factory LearningSession({
    required String id,
    required String childId,
    required String subject,
    required DateTime startedAt,
    DateTime? endedAt,
    @Default(0) int durationMinutes,
    @Default([]) List<String> topicsCovered,
    @Default({}) Map<String, dynamic> data,
  }) = _LearningSession;

  factory LearningSession.fromJson(Map<String, dynamic> json) =>
      _$LearningSessionFromJson(json);
}

enum Subject {
  reading,
  math,
  science,
  creative,
  language,
}

extension SubjectX on Subject {
  String get displayName {
    switch (this) {
      case Subject.reading:
        return 'Membaca';
      case Subject.math:
        return 'Matematika';
      case Subject.science:
        return 'Sains';
      case Subject.creative:
        return 'Kreativitas';
      case Subject.language:
        return 'Bahasa';
    }
  }

  String get emoji {
    switch (this) {
      case Subject.reading:
        return '📖';
      case Subject.math:
        return '🔢';
      case Subject.science:
        return '🔬';
      case Subject.creative:
        return '🎨';
      case Subject.language:
        return '🗣️';
    }
  }
}