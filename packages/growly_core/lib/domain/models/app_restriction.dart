class AppRestriction {
  final String id;
  final String childId;
  final String appPackage;
  final String? appName;
  final String? appIcon;
  final bool isAllowed;
  final int? timeLimitMinutes;
  final Map<String, int> scheduleLimits;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AppRestriction({
    required this.id,
    required this.childId,
    required this.appPackage,
    this.appName,
    this.appIcon,
    required this.isAllowed,
    this.timeLimitMinutes,
    this.scheduleLimits = const {},
    required this.createdAt,
    this.updatedAt,
  });

  factory AppRestriction.fromJson(Map<String, dynamic> json) {
    return AppRestriction(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      appPackage: json['app_package'] as String,
      appName: json['app_name'] as String?,
      appIcon: json['app_icon'] as String?,
      isAllowed: json['is_allowed'] as bool,
      timeLimitMinutes: json['time_limit_minutes'] as int?,
      scheduleLimits: (json['schedule_limits'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'app_package': appPackage,
      'app_name': appName,
      'app_icon': appIcon,
      'is_allowed': isAllowed,
      'time_limit_minutes': timeLimitMinutes,
      'schedule_limits': scheduleLimits,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AppRestriction copyWith({
    String? id,
    String? childId,
    String? appPackage,
    String? appName,
    String? appIcon,
    bool? isAllowed,
    int? timeLimitMinutes,
    Map<String, int>? scheduleLimits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppRestriction(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      appPackage: appPackage ?? this.appPackage,
      appName: appName ?? this.appName,
      appIcon: appIcon ?? this.appIcon,
      isAllowed: isAllowed ?? this.isAllowed,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      scheduleLimits: scheduleLimits ?? this.scheduleLimits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Schedule {
  final String id;
  final String childId;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final String mode; // learning, break, school, sleep
  final bool isEnabled;
  final String? label;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Schedule({
    required this.id,
    required this.childId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.mode,
    this.isEnabled = true,
    this.label,
    required this.createdAt,
    this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      dayOfWeek: json['day_of_week'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      mode: json['mode'] as String,
      isEnabled: json['is_enabled'] as bool? ?? true,
      label: json['label'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'mode': mode,
      'is_enabled': isEnabled,
      'label': label,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isActive {
    if (!isEnabled) return false;
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return currentTime.compareTo(startTime) >= 0 &&
        currentTime.compareTo(endTime) <= 0;
  }

  Schedule copyWith({
    String? id,
    String? childId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? mode,
    bool? isEnabled,
    String? label,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      mode: mode ?? this.mode,
      isEnabled: isEnabled ?? this.isEnabled,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}