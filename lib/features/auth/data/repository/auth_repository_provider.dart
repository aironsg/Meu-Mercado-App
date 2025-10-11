import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

/// Provider global que expõe o repositório de autenticação
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});
