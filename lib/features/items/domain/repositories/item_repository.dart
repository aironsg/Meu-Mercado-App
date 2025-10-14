// lib/features/items/domain/repositories/item_repository.dart

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

  // 🚨 ATUALIZADO: Este método agora é substituído pelo `saveItemInList`
  Future<void> updateItemInList(String listId, ItemEntity updatedItem);

  // 🚨 NOVO: Adiciona um novo item ou atualiza um item existente na lista.
  Future<void> saveItemInList(String listId, ItemEntity itemToSave);

  // 🚨 NOVO: Remove um item de uma lista existente
  Future<void> removeItemFromList(String listId, String itemId);

  // 🚨 NOVO: Remove uma lista completa
  Future<void> deleteList(String listId);
}
