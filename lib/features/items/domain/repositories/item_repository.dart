import '../entities/item_entity.dart';

abstract class ItemRepository {
  Future<void> addItem(ItemEntity item);
  Future<List<ItemEntity>> getItems(String userId);
  Future<void> deleteItem(String userId, String itemId);
}
