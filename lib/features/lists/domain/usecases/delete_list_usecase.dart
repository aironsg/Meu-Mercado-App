import 'package:meu_mercado/features/items/domain/repositories/item_repository.dart';

class DeleteListUseCase {
  final ItemRepository repository;

  DeleteListUseCase(this.repository);

  Future<void> execute(String listId) async {
    await repository.deleteList(listId);
  }
}
