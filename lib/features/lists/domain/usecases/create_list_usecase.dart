import '../entities/shopping_list_entity.dart';
import '../repositories/list_repository.dart';

class CreateListUseCase {
  final ListRepository repository;
  CreateListUseCase(this.repository);

  Future<void> call(ShoppingListEntity list) async {
    await repository.createList(list);
  }
}
