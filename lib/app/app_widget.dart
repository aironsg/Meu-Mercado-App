import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Meu Mercado',
      theme: AppTheme.theme,
      routerConfig: Modular.routerConfig,
      debugShowCheckedModeBanner: false,
    );
  }
}
