import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meu_mercado/features/items/data/models/item_model.dart';
import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';

import '../domain/entities/shopping_list_entity.dart';
import '../domain/repositories/list_repository.dart';
import '../../lists/data/datasources/list_datasource.dart';

class ListRepositoryImpl implements ListRepository {
  final ListDataSource dataSource;
  ListRepositoryImpl(this.dataSource);

  static const String _collectionPath = 'shopping_lists';

  @override
  Future<void> createList(ShoppingListEntity list) async {
    await dataSource.createList(list);
  }

  @override
  Future<List<ShoppingListEntity>> getAllLists() async {
    return await dataSource.getAllLists();
  }

  @override
  Future<ShoppingListEntity?> getLatestList() async {
    return await dataSource.getLatestList();
  }
}
