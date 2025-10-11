import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User?> executeEmail(String email, String password) async {
    return await repository.registerWithEmail(email, password);
  }

  Future<User?> executeGoogle() async {
    return await repository.signInWithGoogle();
  }
}
