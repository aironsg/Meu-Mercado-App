import '../repositories/items_repository.dart';
import '../entities/item_entity.dart';

class UpdateItemUseCase {
  final ItemsRepository repository;
  UpdateItemUseCase(this.repository);

  Future<int> call(ItemEntity item) => repository.updateItem(item);
}
