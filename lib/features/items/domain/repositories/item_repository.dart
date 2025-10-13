import '../entities/item_entity.dart';

abstract class ItemRepository {
  /// Salva uma lista completa de compras no banco de dados.
  /// O `shoppingList` deve ser o payload final contendo userId, data e o array de itens.
  Future<void> saveList(Map<String, dynamic> shoppingList);

  /// Busca os itens de uma categoria específica (ex: 'MERCADO')
  /// na última lista de compras cadastrada pelo usuário.
  Future<List<ItemEntity>> getPreviousListItemsByCategory(String category);
  Future<List<Map<String, dynamic>>> getUserLists();
  Future<Map<String, dynamic>?> getLatestList();
  Future<void> updateItemInList(String listId, ItemEntity updatedItem);
}
