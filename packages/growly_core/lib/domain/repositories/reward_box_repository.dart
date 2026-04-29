import '../../core/errors/failures.dart';
import '../models/reward_box.dart';

abstract class IRewardBoxRepository {
  /// Get all reward boxes for a parent.
  Future<(List<RewardBox>?, Failure?)> getRewardBoxes(String parentId);

  /// Create a new reward box.
  Future<(RewardBox?, Failure?)> createRewardBox(RewardBox box);

  /// Mark a reward box as claimed.
  Future<(RewardBox?, Failure?)> claimRewardBox(String boxId);

  /// Delete a reward box.
  Future<(bool, Failure?)> deleteRewardBox(String boxId);
}