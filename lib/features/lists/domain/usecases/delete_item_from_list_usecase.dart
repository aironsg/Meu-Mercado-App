import 'package:meu_mercado/features/items/domain/repositories/item_repository.dart';

class DeleteItemFromListUseCase {
  // Implementação do caso de uso para deletar um item da lista
  final ItemRepository repository;

  DeleteItemFromListUseCase(this.repository);

  Future<void> execute({required String listId, required String itemId}) async {
    await repository.removeItemFromList(listId, itemId);
  }
}
