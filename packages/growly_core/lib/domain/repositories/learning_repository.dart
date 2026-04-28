import '../models/learning_progress.dart';
import '../../core/errors/failures.dart';

abstract class ILearningRepository {
  Future<(List<LearningProgress>?, Failure?)> getProgress(String childId, {int limit = 50});
  Future<(List<LearningSession>?, Failure?)> getSessions(String childId, {DateTime? from, DateTime? to});
  Future<(LearningProgress?, Failure?)> saveProgress(LearningProgress progress);
  Future<(LearningSession?, Failure?)> startSession(String childId, String subject);
  Future<(LearningSession?, Failure?)> endSession(String sessionId, {int durationMinutes = 0, List<String>? topicsCovered});
  Future<(Map<String, dynamic>?, Failure?)> getStats(String childId);
  Future<(Map<String, dynamic>?, Failure?)> getLesson(String lessonId);
}