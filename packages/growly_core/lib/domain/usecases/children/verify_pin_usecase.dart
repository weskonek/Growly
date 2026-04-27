import '../../repositories/child_repository.dart';
import '../../../core/errors/failures.dart';

class VerifyPinUseCase {
  final IChildRepository _repository;

  VerifyPinUseCase(this._repository);

  Future<(bool, Failure?)> call(String childId, String pin) {
    return _repository.verifyPin(childId, pin);
  }
}
