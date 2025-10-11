import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';

class GetPreviousItemsUseCase {
  final ItemRepository repository;

  GetPreviousItemsUseCase(this.repository);

  /// Busca os itens da lista do mês anterior com base na categoria.
  /// A lógica de "mês anterior" será tratada dentro do repositório.
  Future<List<ItemEntity>> execute(String category) async {
    return await repository.getPreviousListItemsByCategory(category);
  }
}
