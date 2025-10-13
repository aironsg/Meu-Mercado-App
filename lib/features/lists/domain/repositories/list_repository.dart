import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';

import '../../domain/entities/shopping_list_entity.dart';

abstract class ListRepository {
  Future<List<ShoppingListEntity>> getAllLists();
  Future<ShoppingListEntity?> getLatestList();
  Future<void> createList(ShoppingListEntity list);
}
