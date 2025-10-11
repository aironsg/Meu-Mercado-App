import '../entities/item_entity.dart';

abstract class ItemsRepository {
  Stream<List<ItemEntity>> watchItems();
  Future<List<ItemEntity>> getItems();
  Future<int> addItem(ItemEntity item);
  Future<int> updateItem(ItemEntity item);
  Future<int> deleteItem(int id);
}
