import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
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
        // 🚨 CORREÇÃO: Botão de retorno explícito
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Modular.to.pop(), // Navega de volta
        ),
      ),
      backgroundColor: AppColors.background,
      // ... (restante do body)
    );
  }
}
