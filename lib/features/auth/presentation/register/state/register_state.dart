import 'package:firebase_auth/firebase_auth.dart';

class RegisterState {
  final bool loading;
  final User? user;
  final String? error;

  RegisterState({this.loading = false, this.user, this.error});

  RegisterState copyWith({bool? loading, User? user, String? error}) {
    return RegisterState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}
