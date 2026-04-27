import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../growly_core/lib/domain/models/child_profile.dart';

part 'tutor_context.freezed.dart';
part 'tutor_context.g.dart';

@freezed
class TutorContext with _$TutorContext {
  const factory TutorContext({
    required String childId,
    required int age,
    required AgeGroup ageGroup,
    String? name,
    @Default({}) Map<String, dynamic> learningHistory,
    @Default({}) Map<String, dynamic> preferences,
    @Default({}) Map<String, dynamic> sessionData,
  }) = _TutorContext;

  factory TutorContext.fromJson(Map<String, dynamic> json) =>
      _$TutorContextFromJson(json);
}

@freezed
class PromptContext with _$PromptContext {
  const factory PromptContext({
    required TutorContext childContext,
    required String mode,
    required String language,
    @Default(3) int hintLevel, // 1-5, how detailed hints should be
    @Default([]) List<String> conversationHistory,
    @Default({}) Map<String, dynamic> additionalContext,
  }) = _PromptContext;

  factory PromptContext.fromJson(Map<String, dynamic> json) =>
      _$PromptContextFromJson(json);
}

class TutorContextBuilder {
  static TutorContext fromChildProfile(ChildProfile profile) {
    return TutorContext(
      childId: profile.id,
      age: profile.age,
      ageGroup: profile.ageGroup,
      name: profile.name,
    );
  }
}