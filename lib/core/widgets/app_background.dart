// lib/core/widgets/app_background.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget reutilizável que aplica o gradiente de fundo temático
/// em qualquer tela, garantindo consistência de UI.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Gradiente baseado nas cores primárias e de fundo do tema
          colors: [
            AppColors.gradientContrastStart,
            AppColors.gradientContrastMid,
            AppColors.gradientContrastEnd,
          ],
          stops: [0.0, 0.2, 1.0],
        ),
      ),
      child: child,
    );
  }
}
