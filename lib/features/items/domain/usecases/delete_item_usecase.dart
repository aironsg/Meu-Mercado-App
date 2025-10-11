import '../repositories/item_repository.dart';

class DeleteItemUseCase {
  final ItemRepository repository;
  DeleteItemUseCase(this.repository);

  Future<void> execute(String userId, String itemId) async {
    await repository.deleteItem(userId, itemId);
  }
}
