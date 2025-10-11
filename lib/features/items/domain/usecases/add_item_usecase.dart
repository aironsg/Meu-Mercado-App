import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';

class AddItemUseCase {
  final ItemRepository repository;

  AddItemUseCase(this.repository);

  Future<void> execute(ItemEntity item) async {
    await repository.addItem(item);
  }
}
