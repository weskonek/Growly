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

class AiResponse {
  final String content;
  final String type;
  final String? audioUrl;
  final Map<String, dynamic> metadata;

  const AiResponse({
    required this.content,
    required this.type,
    this.audioUrl,
    this.metadata = const {},
  });

  factory AiResponse.fromJson(Map<String, dynamic> json) {
    return AiResponse(
      content: json['content'] as String,
      type: json['type'] as String? ?? 'general',
      audioUrl: json['audioUrl'] as String? ?? json['audio_url'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'type': type,
      'audioUrl': audioUrl,
      'metadata': metadata,
    };
  }

  AiResponse copyWith({
    String? content,
    String? type,
    String? audioUrl,
    Map<String, dynamic>? metadata,
  }) {
    return AiResponse(
      content: content ?? this.content,
      type: type ?? this.type,
      audioUrl: audioUrl ?? this.audioUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

class AiMessage {
  final String id;
  final String role;
  final String content;
  final DateTime? timestamp;
  final String? type;

  const AiMessage({
    required this.id,
    required this.role,
    required this.content,
    this.timestamp,
    this.type,
  });

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ?? 'assistant',
      content: json['content'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp?.toIso8601String(),
      'type': type,
    };
  }

  AiMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    String? type,
  }) {
    return AiMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}

class AiSession {
  final String id;
  final String childId;
  final String mode;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<AiMessage> messages;
  final Map<String, dynamic> context;

  const AiSession({
    required this.id,
    required this.childId,
    required this.mode,
    required this.startedAt,
    this.endedAt,
    this.messages = const [],
    this.context = const {},
  });

  factory AiSession.fromJson(Map<String, dynamic> json) {
    return AiSession(
      id: json['id'] as String,
      childId: json['child_id'] as String? ?? json['childId'] as String,
      mode: json['mode'] as String,
      startedAt: DateTime.parse(json['started_at'] as String? ?? json['startedAt'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : json['endedAt'] != null
              ? DateTime.parse(json['endedAt'] as String)
              : null,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => AiMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      context: (json['context'] as Map<String, dynamic>?) ??
          (json['metadata'] as Map<String, dynamic>?) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'mode': mode,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'messages': messages.map((e) => e.toJson()).toList(),
      'metadata': context,
    };
  }

  AiSession copyWith({
    String? id,
    String? childId,
    String? mode,
    DateTime? startedAt,
    DateTime? endedAt,
    List<AiMessage>? messages,
    Map<String, dynamic>? context,
  }) {
    return AiSession(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      mode: mode ?? this.mode,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      messages: messages ?? this.messages,
      context: context ?? this.context,
    );
  }
}