import 'package:freezed_annotation/freezed_annotation.dart';

part 'screen_time.freezed.dart';
part 'screen_time.g.dart';

@freezed
class ScreenTimeRecord with _$ScreenTimeRecord {
  const factory ScreenTimeRecord({
    required String id,
    required String childId,
    required String appPackage,
    String? appName,
    required int durationMinutes,
    required DateTime date,
    required DateTime createdAt,
  }) = _ScreenTimeRecord;

  factory ScreenTimeRecord.fromJson(Map<String, dynamic> json) =>
      _$ScreenTimeRecordFromJson(json);
}

@freezed
class DailyScreenTime with _$DailyScreenTime {
  const factory DailyScreenTime({
    required String childId,
    required DateTime date,
    required int totalMinutes,
    @Default(0) int learningMinutes,
    @Default(0) int entertainmentMinutes,
    @Default({}) Map<String, int> appBreakdown,
  }) = _DailyScreenTime;

  factory DailyScreenTime.fromJson(Map<String, dynamic> json) =>
      _$DailyScreenTimeFromJson(json);
}

@freezed
class ScreenTimeSettings with _$ScreenTimeSettings {
  const factory ScreenTimeSettings({
    required String childId,
    @Default(120) int dailyLimitMinutes,
    @Default(true) bool isEnabled,
    @Default({}) Map<String, int> appLimits,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ScreenTimeSettings;

  factory ScreenTimeSettings.fromJson(Map<String, dynamic> json) =>
      _$ScreenTimeSettingsFromJson(json);
}

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