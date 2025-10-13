import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../state/login_state.dart';
import '../../../../home/presentation/pages/home_page.dart';
import '../../../data/repository/auth_repository_provider.dart';

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>(
      (ref) => LoginController(ref),
    );

class LoginController extends StateNotifier<LoginState> {
  final Ref ref;
  late final LoginUseCase _useCase;

  LoginController(this.ref) : super(LoginState()) {
    _useCase = LoginUseCase(ref.read(authRepositoryProvider));
  }

  Future<void> loginWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    state = state.copyWith(loading: true);
    try {
      final user = await _useCase.executeEmail(email, password);
      if (user != null) {
        state = state.copyWith(user: user, loading: false);
        Modular.to.pushReplacementNamed('/home');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    state = state.copyWith(loading: true);
    try {
      final user = await _useCase.executeGoogle();
      if (user != null) {
        state = state.copyWith(user: user, loading: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}
