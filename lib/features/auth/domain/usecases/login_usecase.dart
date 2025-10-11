import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User?> executeEmail(String email, String password) async {
    return await repository.signInWithEmail(email, password);
  }

  Future<User?> executeGoogle() async {
    return await repository.signInWithGoogle();
  }
}
