import '../../repositories/child_repository.dart';
import '../../models/child_profile.dart';
import '../../../core/errors/failures.dart';

class UpdateChildUseCase {
  final IChildRepository _repository;

  UpdateChildUseCase(this._repository);

  Future<(ChildProfile?, Failure?)> call(ChildProfile child) {
    return _repository.updateChild(child);
  }
}
