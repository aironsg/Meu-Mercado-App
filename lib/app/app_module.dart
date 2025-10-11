import 'package:flutter_modular/flutter_modular.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/auth/presentation/login/pages/login_page.dart';
import '../features/home/presentation/home_page.dart';

class AppModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const SplashPage());
    r.child('/login', child: (_) => const LoginPage());
    r.child('/home', child: (_) => const HomePage());
  }
}
