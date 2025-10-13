import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';
import 'package:meu_mercado/features/items/domain/repositories/item_repository.dart';

class UpdateItemInListUseCase {
  final ItemRepository repository;

  UpdateItemInListUseCase(this.repository);

  /// Atualiza um item específico dentro de uma lista existente no servidor.
  Future<void> execute({
    required String listId,
    required ItemEntity updatedItem,
  }) async {
    // O repositório lida com a complexidade de encontrar a lista e atualizar o array interno.
    await repository.updateItemInList(listId, updatedItem);
  }
}
