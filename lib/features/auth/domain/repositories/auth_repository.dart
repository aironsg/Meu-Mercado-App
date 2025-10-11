import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signInWithGoogle();
  Future<void> signOut();
  Future<User?> registerWithEmail(String name, String email, String password);
  Future<void> sendPasswordReset(String email);
}
