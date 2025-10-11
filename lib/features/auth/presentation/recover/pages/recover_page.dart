import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/app_assets.dart';
import '../controller/recover_controller.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar conta'),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset(AppAssets.logo, height: 150),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail cadastrado',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            state.loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      final email = _emailController.text.trim();
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Informe o e-mail')),
                        );
                        return;
                      }
                      controller.sendResetEmail(context, email);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Enviar e-mail de recuperação'),
                  ),
            const SizedBox(height: 12),
            if (state.message != null)
              Text(state.message!, style: const TextStyle(color: Colors.green)),
            if (state.error != null)
              Text(state.error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
