import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_mercado/core/widgets/app_background.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/app_assets.dart';
import '../controller/recover_controller.dart';
import '../state/recover_state.dart'; // Importa o estado para o listener

class RecoverPage extends ConsumerStatefulWidget {
  const RecoverPage({super.key});

  @override
  ConsumerState<RecoverPage> createState() => _RecoverPageState();
}

class _RecoverPageState extends ConsumerState<RecoverPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recoverControllerProvider);
    final controller = ref.read(recoverControllerProvider.notifier);

    // Ouve as mudanças de estado para exibir mensagens de sucesso ou erro via SnackBar.
    ref.listen<RecoverState>(recoverControllerProvider, (previous, next) {
      // Exibe mensagem de erro
      if (next.error != null &&
          next.error != previous?.error &&
          !next.loading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      // Exibe mensagem de sucesso (o controller já trata a navegação de volta)
      if (next.message != null &&
          next.message != previous?.message &&
          !next.loading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message!),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar conta'),
        backgroundColor: AppColors.primary,
        // Botão de retorno explícito
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Modular.to.pop(), // Navega de volta
        ),
      ),
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppAssets.logo, height: 220),
                    const SizedBox(height: 24),

                    // Texto Informativo
                    const Text(
                      'Esqueceu sua senha? Sem problemas! Insira seu e-mail de cadastro abaixo e enviaremos um link para você redefini-la.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimaryLight,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Campo Email
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão de Enviar Link
                    ElevatedButton(
                      onPressed: state.loading
                          ? null
                          : () {
                              controller.sendResetEmail(
                                context,
                                _emailController.text,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Enviar Link de Recuperação',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
