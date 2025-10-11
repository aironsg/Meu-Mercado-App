import '../repositories/items_repository.dart';

class DeleteItemUseCase {
  final ItemsRepository repository;
  DeleteItemUseCase(this.repository);

  Future<int> call(int id) => repository.deleteItem(id);
}
