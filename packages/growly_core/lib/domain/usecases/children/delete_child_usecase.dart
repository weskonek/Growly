import '../../repositories/child_repository.dart';
import '../../../core/errors/failures.dart';

class DeleteChildUseCase {
  final IChildRepository _repository;

  DeleteChildUseCase(this._repository);

  Future<(bool, Failure?)> call(String childId) {
    return _repository.deleteChild(childId);
  }
}
