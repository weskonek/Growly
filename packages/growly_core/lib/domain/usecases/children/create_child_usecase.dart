import '../../repositories/child_repository.dart';
import '../../models/child_profile.dart';
import '../../../core/errors/failures.dart';

class CreateChildUseCase {
  final IChildRepository _repository;

  CreateChildUseCase(this._repository);

  Future<(ChildProfile?, Failure?)> call(ChildProfile child) {
    return _repository.createChild(child);
  }
}
