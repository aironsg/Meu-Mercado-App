import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User?> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    return await repository.registerWithEmail(name, email, password);
  }

  Future<User?> executeGoogle() async {
    return await repository.signInWithGoogle();
  }
}
