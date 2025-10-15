// mock_item_repository.dart (Arquivo temporário para testes)

import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';
import 'package:meu_mercado/features/items/domain/repositories/item_repository.dart';

// 🚨 Mock que retorna listas de Setembro e Outubro de 2025
class MockItemRepositoryImpl implements ItemRepository {
  // Define as datas mock
  final DateTime october = DateTime(2025, 10, 15);
  final DateTime september = DateTime(2025, 9, 15);

  // Itens para Outubro (O) - Arroz (16.50), Banana (4.50), Sabão (12.00)
  final ItemEntity itemO1 = ItemEntity(
    id: 'o_id1',
    name: 'Arroz',
    category: 'MERCADO',
    quantity: 2,
    price: 16.50,
  );
  final ItemEntity itemO2 = ItemEntity(
    id: 'o_id2',
    name: 'Banana',
    category: 'FEIRA',
    quantity: 5,
    price: 4.50,
  );
  final ItemEntity itemO3 = ItemEntity(
    id: 'o_id3',
    name: 'Sabão em Pó',
    category: 'CASA',
    quantity: 1,
    price: 12.00,
  );

  // Itens para Setembro (S) - Arroz (15.00), Banana (5.00), Frango (18.00)
  final ItemEntity itemS1 = ItemEntity(
    id: 's_id1',
    name: 'Arroz',
    category: 'MERCADO',
    quantity: 2,
    price: 15.00,
  ); // Mais barato
  final ItemEntity itemS2 = ItemEntity(
    id: 's_id2',
    name: 'Banana',
    category: 'FEIRA',
    quantity: 5,
    price: 5.00,
  ); // Mais caro
  final ItemEntity itemS3 = ItemEntity(
    id: 's_id3',
    name: 'Frango',
    category: 'MERCADO',
    quantity: 3,
    price: 18.00,
  );

  @override
  Future<List<Map<String, dynamic>>> getUserLists() async {
    return [
      // Lista de Outubro (Mais Recente)
      {
        'id': 'list_o_id',
        'createdAt': october,
        'items': [itemO1, itemO2, itemO3],
      },
      // Lista de Setembro (Anterior)
      {
        'id': 'list_s_id',
        'createdAt': september,
        'items': [itemS1, itemS2, itemS3],
      },
    ];
  }

  // Implementações de fallback para métodos não relevantes para o teste de estatísticas
  @override
  Future<Map<String, dynamic>?> getLatestList() async {
    final lists = await getUserLists();
    return lists.isNotEmpty ? lists.first : null;
  }

  @override
  Future<List<ItemEntity>> getPreviousListItemsByCategory(
    String category,
  ) async => [];
  @override
  Future<void> saveList(Map<String, dynamic> shoppingList) async {}
  @override
  Future<void> saveItemInList(String listId, ItemEntity itemToSave) async {}
  @override
  Future<void> updateItemInList(String listId, ItemEntity updatedItem) async {}
  @override
  Future<void> removeItemFromList(String listId, String itemId) async {}
  @override
  Future<void> deleteList(String listId) async {}
}
