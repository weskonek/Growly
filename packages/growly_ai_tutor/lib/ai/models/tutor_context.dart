import 'package:growly_core/growly_core.dart';

class TutorContext {
  final String childId;
  final int age;
  final AgeGroup ageGroup;
  final String? name;
  final Map<String, dynamic> learningHistory;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> sessionData;

  const TutorContext({
    required this.childId,
    required this.age,
    required this.ageGroup,
    this.name,
    this.learningHistory = const {},
    this.preferences = const {},
    this.sessionData = const {},
  });

  factory TutorContext.fromJson(Map<String, dynamic> json) {
    return TutorContext(
      childId: json['childId'] as String? ?? json['child_id'] as String,
      age: json['age'] as int? ?? 8,
      ageGroup: AgeGroup.values[json['ageGroup'] as int? ?? json['age_group'] as int? ?? 1],
      name: json['name'] as String?,
      learningHistory: (json['learningHistory'] as Map<String, dynamic>?) ??
          (json['learning_history'] as Map<String, dynamic>?) ??
          {},
      preferences: (json['preferences'] as Map<String, dynamic>?) ?? {},
      sessionData: (json['sessionData'] as Map<String, dynamic>?) ??
          (json['session_data'] as Map<String, dynamic>?) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'age': age,
      'ageGroup': ageGroup.index,
      'name': name,
      'learningHistory': learningHistory,
      'preferences': preferences,
      'sessionData': sessionData,
    };
  }

  TutorContext copyWith({
    String? childId,
    int? age,
    AgeGroup? ageGroup,
    String? name,
    Map<String, dynamic>? learningHistory,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? sessionData,
  }) {
    return TutorContext(
      childId: childId ?? this.childId,
      age: age ?? this.age,
      ageGroup: ageGroup ?? this.ageGroup,
      name: name ?? this.name,
      learningHistory: learningHistory ?? this.learningHistory,
      preferences: preferences ?? this.preferences,
      sessionData: sessionData ?? this.sessionData,
    );
  }
}

class PromptContext {
  final TutorContext childContext;
  final String mode;
  final String language;
  final int hintLevel;
  final List<String> conversationHistory;
  final Map<String, dynamic> additionalContext;

  const PromptContext({
    required this.childContext,
    required this.mode,
    required this.language,
    this.hintLevel = 3,
    this.conversationHistory = const [],
    this.additionalContext = const {},
  });

  factory PromptContext.fromJson(Map<String, dynamic> json) {
    return PromptContext(
      childContext: TutorContext.fromJson(json['childContext'] as Map<String, dynamic>),
      mode: json['mode'] as String? ?? 'general',
      language: json['language'] as String? ?? 'id',
      hintLevel: json['hintLevel'] as int? ?? json['hint_level'] as int? ?? 3,
      conversationHistory: (json['conversationHistory'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      additionalContext: (json['additionalContext'] as Map<String, dynamic>?) ??
          (json['additional_context'] as Map<String, dynamic>?) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'childContext': childContext.toJson(),
      'mode': mode,
      'language': language,
      'hintLevel': hintLevel,
      'conversationHistory': conversationHistory,
      'additionalContext': additionalContext,
    };
  }
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