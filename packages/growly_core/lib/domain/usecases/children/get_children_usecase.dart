import '../../repositories/child_repository.dart';
import '../../models/child_profile.dart';
import '../../../core/errors/failures.dart';

class GetChildrenUseCase {
  final IChildRepository _repository;

  GetChildrenUseCase(this._repository);

  Future<(List<ChildProfile>?, Failure?)> call(String parentId) {
    return _repository.getChildren(parentId);
  }
}
