import '../../repositories/child_repository.dart';
import '../../models/child_profile.dart';
import '../../../core/errors/failures.dart';

class GetChildUseCase {
  final IChildRepository _repository;

  GetChildUseCase(this._repository);

  Future<(ChildProfile?, Failure?)> call(String childId) {
    return _repository.getChild(childId);
  }
}
