import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/auth_repository_provider.dart';
import '../../domain/usecases/recover_usecase.dart';
import 'recover_state.dart';

final recoverControllerProvider =
    StateNotifierProvider<RecoverController, RecoverState>(
      (ref) => RecoverController(ref),
    );

class RecoverController extends StateNotifier<RecoverState> {
  final Ref ref;
  late final RecoverUseCase _useCase;

  RecoverController(this.ref) : super(RecoverState()) {
    _useCase = RecoverUseCase(ref.read(authRepositoryProvider));
  }

  Future<void> sendResetEmail(BuildContext context, String email) async {
    state = state.copyWith(loading: true, error: null, message: null);
    try {
      await _useCase.execute(email);
      state = state.copyWith(
        loading: false,
        message:
            'E-mail de recuperação enviado. Verifique sua caixa de entrada.',
      );
      // opcional: voltar à tela de login após curto delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).maybePop();
      });
    } catch (e) {
      state = state.copyWith(loading: false, error: _parseError(e));
    }
  }

  String _parseError(Object e) {
    // Parser simples — customize conforme suas necessidades
    final msg = e.toString();
    if (msg.contains('user-not-found')) return 'E-mail não cadastrado.';
    if (msg.contains('invalid-email')) return 'E-mail inválido.';
    return 'Erro ao enviar e-mail. Tente novamente.';
  }
}
