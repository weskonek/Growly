import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_restriction.freezed.dart';
part 'app_restriction.g.dart';

@freezed
class AppRestriction with _$AppRestriction {
  const factory AppRestriction({
    required String id,
    required String childId,
    required String appPackage,
    String? appName,
    String? appIcon,
    required bool isAllowed,
    @Default(null) int? timeLimitMinutes,
    @Default({}) Map<String, int> scheduleLimits,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _AppRestriction;

  factory AppRestriction.fromJson(Map<String, dynamic> json) =>
      _$AppRestrictionFromJson(json);
}

@freezed
class Schedule with _$Schedule {
  const factory Schedule({
    required String id,
    required String childId,
    required int dayOfWeek, // 1 = Monday, 7 = Sunday
    required String startTime, // HH:mm format
    required String endTime, // HH:mm format
    required String mode, // learning, break, school, sleep
    @Default(true) bool isEnabled,
    String? label,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);
}

extension ScheduleX on Schedule {
  bool get isActive {
    if (!isEnabled) return false;
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return currentTime.compareTo(startTime) >= 0 && currentTime.compareTo(endTime) <= 0;
  }
}