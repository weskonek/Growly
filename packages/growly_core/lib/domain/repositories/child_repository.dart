import '../models/child_profile.dart';
import '../../core/errors/failures.dart';

abstract class IChildRepository {
  Future<(List<ChildProfile>?, Failure?)> getChildren(String parentId);
  Future<(ChildProfile?, Failure?)> getChild(String childId);
  Future<(ChildProfile?, Failure?)> createChild(ChildProfile child);
  Future<(ChildProfile?, Failure?)> updateChild(ChildProfile child);
  Future<(bool, Failure?)> deleteChild(String childId);
  Future<(bool, Failure?)> verifyPin(String childId, String pin);
}