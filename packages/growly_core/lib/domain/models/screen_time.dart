enum ScreenTimeMode {
  normal,
  learning,
  breakTime,
  schoolMode,
  sleepMode,
}

extension ScreenTimeModeX on ScreenTimeMode {
  String get displayName {
    switch (this) {
      case ScreenTimeMode.normal:
        return 'Normal';
      case ScreenTimeMode.learning:
        return 'Mode Belajar';
      case ScreenTimeMode.breakTime:
        return 'Waktu Istirahat';
      case ScreenTimeMode.schoolMode:
        return 'Mode Sekolah';
      case ScreenTimeMode.sleepMode:
        return 'Mode Tidur';
    }
  }

  String get emoji {
    switch (this) {
      case ScreenTimeMode.normal:
        return '📱';
      case ScreenTimeMode.learning:
        return '📚';
      case ScreenTimeMode.breakTime:
        return '☕';
      case ScreenTimeMode.schoolMode:
        return '🏫';
      case ScreenTimeMode.sleepMode:
        return '😴';
    }
  }
}

class ScreenTimeRecord {
  final String id;
  final String childId;
  final String appPackage;
  final String? appName;
  final int durationMinutes;
  final DateTime date;
  final DateTime createdAt;

  const ScreenTimeRecord({
    required this.id,
    required this.childId,
    required this.appPackage,
    this.appName,
    required this.durationMinutes,
    required this.date,
    required this.createdAt,
  });

  factory ScreenTimeRecord.fromJson(Map<String, dynamic> json) {
    return ScreenTimeRecord(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      appPackage: json['app_package'] as String,
      appName: json['app_name'] as String?,
      durationMinutes: json['duration_minutes'] as int,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'app_package': appPackage,
      'app_name': appName,
      'duration_minutes': durationMinutes,
      'date': date.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }

  ScreenTimeRecord copyWith({
    String? id,
    String? childId,
    String? appPackage,
    String? appName,
    int? durationMinutes,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return ScreenTimeRecord(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      appPackage: appPackage ?? this.appPackage,
      appName: appName ?? this.appName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DailyScreenTime {
  final String childId;
  final DateTime date;
  final int totalMinutes;
  final int learningMinutes;
  final int entertainmentMinutes;
  final Map<String, int> appBreakdown;

  const DailyScreenTime({
    required this.childId,
    required this.date,
    required this.totalMinutes,
    this.learningMinutes = 0,
    this.entertainmentMinutes = 0,
    this.appBreakdown = const {},
  });

  factory DailyScreenTime.fromJson(Map<String, dynamic> json) {
    final dateValue = json['date'];
    DateTime parsedDate;
    if (dateValue is String) {
      parsedDate = DateTime.parse(dateValue);
    } else if (dateValue is Map<String, dynamic>) {
      parsedDate = DateTime.parse(dateValue['date'] as String);
    } else {
      parsedDate = DateTime.now();
    }
    return DailyScreenTime(
      childId: json['child_id'] as String,
      date: parsedDate,
      totalMinutes: json['total_minutes'] as int? ?? 0,
      learningMinutes: json['learning_minutes'] as int? ?? 0,
      entertainmentMinutes: json['entertainment_minutes'] as int? ?? 0,
      appBreakdown: (json['app_breakdown'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'child_id': childId,
      'date': date.toIso8601String().split('T')[0],
      'total_minutes': totalMinutes,
      'learning_minutes': learningMinutes,
      'entertainment_minutes': entertainmentMinutes,
      'app_breakdown': appBreakdown,
    };
  }

  DailyScreenTime copyWith({
    String? childId,
    DateTime? date,
    int? totalMinutes,
    int? learningMinutes,
    int? entertainmentMinutes,
    Map<String, int>? appBreakdown,
  }) {
    return DailyScreenTime(
      childId: childId ?? this.childId,
      date: date ?? this.date,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      learningMinutes: learningMinutes ?? this.learningMinutes,
      entertainmentMinutes: entertainmentMinutes ?? this.entertainmentMinutes,
      appBreakdown: appBreakdown ?? this.appBreakdown,
    );
  }
}

class ScreenTimeSettings {
  final String childId;
  final int dailyLimitMinutes;
  final bool isEnabled;
  final Map<String, int> appLimits;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ScreenTimeSettings({
    required this.childId,
    this.dailyLimitMinutes = 120,
    this.isEnabled = true,
    this.appLimits = const {},
    required this.createdAt,
    this.updatedAt,
  });

  factory ScreenTimeSettings.fromJson(Map<String, dynamic> json) {
    return ScreenTimeSettings(
      childId: json['child_id'] as String,
      dailyLimitMinutes: json['daily_limit_minutes'] as int? ?? 120,
      isEnabled: json['is_enabled'] as bool? ?? true,
      appLimits: (json['app_limits'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          (json['appLimits'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'child_id': childId,
      'daily_limit_minutes': dailyLimitMinutes,
      'is_enabled': isEnabled,
      'app_limits': appLimits,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ScreenTimeSettings copyWith({
    String? childId,
    int? dailyLimitMinutes,
    bool? isEnabled,
    Map<String, int>? appLimits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScreenTimeSettings(
      childId: childId ?? this.childId,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      isEnabled: isEnabled ?? this.isEnabled,
      appLimits: appLimits ?? this.appLimits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}