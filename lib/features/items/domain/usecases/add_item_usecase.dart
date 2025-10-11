import '../repositories/items_repository.dart';
import '../entities/item_entity.dart';

class AddItemUseCase {
  final ItemsRepository repository;
  AddItemUseCase(this.repository);

  Future<int> call(ItemEntity item) => repository.addItem(item);
}
