import '../models/app_restriction.dart';
import '../../core/errors/failures.dart';

abstract class IAppRestrictionRepository {
  Future<(List<AppRestriction>?, Failure?)> getRestrictions(String childId);
  Future<(AppRestriction?, Failure?)> saveRestriction(AppRestriction restriction);
  Future<(bool, Failure?)> deleteRestriction(String restrictionId);
  Future<(List<Schedule>?, Failure?)> getSchedules(String childId);
  Future<(Schedule?, Failure?)> saveSchedule(Schedule schedule);
  Future<(bool, Failure?)> deleteSchedule(String scheduleId);
}