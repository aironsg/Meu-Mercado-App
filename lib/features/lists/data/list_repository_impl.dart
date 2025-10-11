import '../domain/entities/shopping_list_entity.dart';
import '../domain/repositories/list_repository.dart';
import '../../lists/data/datasources/list_datasource.dart';

class ListRepositoryImpl implements ListRepository {
  final ListDataSource dataSource;
  ListRepositoryImpl(this.dataSource);

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
