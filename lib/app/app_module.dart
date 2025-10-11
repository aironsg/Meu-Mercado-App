import 'package:flutter_modular/flutter_modular.dart';
import 'package:meu_mercado/features/history/presentation/pages/history_page.dart';
import 'package:meu_mercado/features/items/presentation/pages/item_page.dart';
import 'package:meu_mercado/features/lists/presentation/pages/lists_page.dart';
import 'package:meu_mercado/features/profile/presentation/pages/profile_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/auth/presentation/login/pages/login_page.dart';
import '../features/home/presentation/pages/home_page.dart';

class AppModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const SplashPage());
    r.child('/login', child: (_) => const LoginPage());
    r.child('/home', child: (_) => const HomePage());
    r.child('/profile', child: (_) => const ProfilePage());
    // 🚨 NOVA ROTA: Estatísticas
    r.child('/history', child: (_) => const HistoryPage());
    // Rota para listas/tabela
    r.child('/lists', child: (_) => const ListPage());
    // Rota de cadastro/edição (item deve ser o último para pegar argumentos)
    r.child('/item', child: (args) => const ItemPage());
  }
}
