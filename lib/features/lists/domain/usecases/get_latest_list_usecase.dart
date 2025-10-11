import '../entities/shopping_list_entity.dart';
import '../repositories/list_repository.dart';

import '../../../../features/items/domain/repositories/item_repository.dart';

class GetLatestListUseCase {
  final ItemRepository repository;

  GetLatestListUseCase(this.repository);

  /// Busca o último registro de lista de compras cadastrada pelo usuário.
  /// Retorna um Map<String, dynamic> contendo 'id', 'createdAt', e 'items'.
  Future<Map<String, dynamic>?> execute() async {
    return await repository.getLatestList();
  }
}
