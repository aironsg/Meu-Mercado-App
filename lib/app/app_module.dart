// lib/app/app_module.dart

import 'package:flutter_modular/flutter_modular.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/auth/presentation/login/pages/login_page.dart';
import '../features/auth/presentation/recover/pages/recover_page.dart';
import '../features/auth/presentation/register/pages/register_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/lists/presentation/pages/lists_page.dart';
import '../features/items/presentation/pages/item_page.dart';
import '../features/history/presentation/pages/history_page.dart';

class AppModule extends Module {
  @override
  void routes(RouteManager r) {
    // 1. Rota de inicialização (checa autenticação)
    r.child('/', child: (_) => const SplashPage());

    // 2. Rotas de Autenticação
    r.child('/login', child: (_) => const LoginPage());
    r.child('/register', child: (_) => const RegisterPage());
    r.child('/recover', child: (_) => const RecoverPage());

    // 3. Rotas Principais do App (após login)
    r.child('/home', child: (_) => const HomePage());
    r.child('/profile', child: (_) => const ProfilePage());

    // 4. Rotas de Listas e Análise
    r.child('/lists', child: (_) => const ListPage());

    // 🚨 REVERTIDO: Voltando a usar o HistoryPage diretamente para ler do Firebase.
    r.child('/history', child: (_) => const HistoryPage());

    r.child('/item', child: (_) => ItemPage(itemToEdit: r.args.data));
  }

  @override
  void binds(Injector i) {
    // Manter binds vazios se estiver usando Riverpod
  }
}
