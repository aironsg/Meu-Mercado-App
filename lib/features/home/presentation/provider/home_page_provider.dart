import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../items/data/repositories/item_repository_impl.dart';
import '../../../items/domain/repositories/item_repository.dart';
import '../../../lists/domain/usecases/get_latest_list_usecase.dart';

// 1. Provedor do Repositório (Base)
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepositoryImpl();
});

// 2. Provedor do Use Case (Depende do Repositório)
final getLatestListUseCaseProvider = Provider(
  (ref) => GetLatestListUseCase(ref.read(itemRepositoryProvider)),
);

// 3. Provedor que expõe a Última Lista (o que o HomePage consome)
final getLatestListProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  final itemRepo = ItemRepositoryImpl();
  final useCase = GetLatestListUseCase(itemRepo);
  return await useCase.execute();
});
