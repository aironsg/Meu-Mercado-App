import '../repositories/items_repository.dart';
import '../entities/item_entity.dart';

class GetItemsUseCase {
  final ItemsRepository repository;
  GetItemsUseCase(this.repository);

  Stream<List<ItemEntity>> call() => repository.watchItems();
}
