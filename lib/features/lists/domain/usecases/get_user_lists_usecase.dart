import 'package:meu_mercado/features/items/domain/repositories/item_repository.dart';

import 'package:flutter/foundation.dart';

class GetUserListsUseCase {
  // Nota: Reutilizamos o ItemRepository, que já contém os métodos de Listagem.
  final ItemRepository repository;

  GetUserListsUseCase(this.repository);

  /// Executa a busca de todas as listas de compras do usuário.
  /// Retorna uma lista de Maps, onde cada Map representa uma lista completa.
  Future<List<Map<String, dynamic>>> execute() async {
    try {
      return await repository.getUserLists();
    } catch (e) {
      debugPrint('Erro ao buscar listas no UseCase: $e');
      rethrow;
    }
  }
}
