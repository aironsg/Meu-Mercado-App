import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../data/repository/auth_repository_provider.dart';
import '../state/register_state.dart';
import '../../../../home/presentation/pages/home_page.dart';

final registerControllerProvider =
    StateNotifierProvider<RegisterController, RegisterState>(
      (ref) => RegisterController(ref),
    );

class RegisterController extends StateNotifier<RegisterState> {
  final Ref ref;
  late final RegisterUseCase _useCase;

  RegisterController(this.ref) : super(RegisterState()) {
    _useCase = RegisterUseCase(ref.read(authRepositoryProvider));
  }

  Future<void> registerWithEmail(
    BuildContext context,
    String name,
    String email,
    String password,
  ) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _useCase.registerWithEmail(name, email, password);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> registerWithGoogle(BuildContext context) async {
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
