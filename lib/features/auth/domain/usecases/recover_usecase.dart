import '../../domain/repositories/auth_repository.dart';

class RecoverUseCase {
  final AuthRepository repository;
  RecoverUseCase(this.repository);

  Future<void> execute(String email) async {
    await repository.sendPasswordReset(email);
  }
}
