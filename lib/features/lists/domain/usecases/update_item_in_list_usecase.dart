// lib/features/lists/domain/usecases/update_item_in_list_usecase.dart

import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';
import 'package:meu_mercado/features/items/domain/repositories/item_repository.dart';

class UpdateItemInListUseCase {
  final ItemRepository repository;

  UpdateItemInListUseCase(this.repository);

  /// Atualiza ou ADICIONA um item específico dentro de uma lista existente no servidor.
  Future<void> execute({
    required String listId,
    required ItemEntity updatedItem,
  }) async {
    // 🚨 ATUALIZADO: Usando saveItemInList, que suporta ADD e UPDATE
    await repository.saveItemInList(listId, updatedItem);
  }
}
