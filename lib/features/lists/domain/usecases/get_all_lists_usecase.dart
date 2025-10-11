import '../entities/shopping_list_entity.dart';
import '../repositories/list_repository.dart';

class GetAllListsUseCase {
  final ListRepository repository;
  GetAllListsUseCase(this.repository);

  Future<List<ShoppingListEntity>> call() async {
    return await repository.getAllLists();
  }
}
