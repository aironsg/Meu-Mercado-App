import 'package:firebase_auth/firebase_auth.dart';

class LoginState {
  final bool loading;
  final User? user;
  final String? error;

  LoginState({this.loading = false, this.user, this.error});

  LoginState copyWith({bool? loading, User? user, String? error}) {
    return LoginState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}
