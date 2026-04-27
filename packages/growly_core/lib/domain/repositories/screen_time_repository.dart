import '../models/screen_time.dart';
import '../../core/errors/failures.dart';

abstract class IScreenTimeRepository {
  Future<(List<ScreenTimeRecord>?, Failure?)> getRecords(String childId, DateTime date);
  Future<(DailyScreenTime?, Failure?)> getDailyScreenTime(String childId, DateTime date);
  Future<(ScreenTimeSettings?, Failure?)> getSettings(String childId);
  Future<(ScreenTimeSettings?, Failure?)> saveSettings(ScreenTimeSettings settings);
  Future<(bool, Failure?)> recordUsage(String childId, String appPackage, {String? appName, int durationMinutes = 0});
}