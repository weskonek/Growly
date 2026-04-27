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

class LearningProgress {
  final String id;
  final String childId;
  final String subject;
  final String topic;
  final int score;
  final bool completed;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? sessionId;
  final Map<String, dynamic> metadata;

  const LearningProgress({
    required this.id,
    required this.childId,
    required this.subject,
    required this.topic,
    this.score = 0,
    this.completed = false,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
    this.sessionId,
    this.metadata = const {},
  });

  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    return LearningProgress(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      subject: json['subject'] as String,
      topic: json['topic'] as String,
      score: json['score'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      sessionId: json['session_id'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'subject': subject,
      'topic': topic,
      'score': score,
      'completed': completed,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'session_id': sessionId,
      'metadata': metadata,
    };
  }

  LearningProgress copyWith({
    String? id,
    String? childId,
    String? subject,
    String? topic,
    int? score,
    bool? completed,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) {
    return LearningProgress(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      score: score ?? this.score,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sessionId: sessionId ?? this.sessionId,
      metadata: metadata ?? this.metadata,
    );
  }
}

class LearningSession {
  final String id;
  final String childId;
  final String subject;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationMinutes;
  final List<String> topicsCovered;
  final Map<String, dynamic> data;

  const LearningSession({
    required this.id,
    required this.childId,
    required this.subject,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes = 0,
    this.topicsCovered = const [],
    this.data = const {},
  });

  factory LearningSession.fromJson(Map<String, dynamic> json) {
    return LearningSession(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      subject: json['subject'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      topicsCovered: (json['topics_covered'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      data: (json['data'] as Map<String, dynamic>?) ??
          (json['metadata'] as Map<String, dynamic>?) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'subject': subject,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'topics_covered': topicsCovered,
      'metadata': data,
    };
  }

  LearningSession copyWith({
    String? id,
    String? childId,
    String? subject,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationMinutes,
    List<String>? topicsCovered,
    Map<String, dynamic>? data,
  }) {
    return LearningSession(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      subject: subject ?? this.subject,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      topicsCovered: topicsCovered ?? this.topicsCovered,
      data: data ?? this.data,
    );
  }
}