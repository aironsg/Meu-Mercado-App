import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_mercado/features/home/presentation/provider/home_page_provider.dart';
import 'package:meu_mercado/features/items/data/repositories/item_repository_impl.dart';
import 'package:meu_mercado/features/items/domain/repositories/item_repository.dart';
import 'package:meu_mercado/features/lists/domain/usecases/get_user_lists_usecase.dart';
import 'package:meu_mercado/features/lists/presentation/controller/list_controller.dart';
import '../state/list_state.dart';

// 1. Provedor do Repositório (Base)
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepositoryImpl();
});

// 2. Provedor do Use Case (Depende do Repositório)
final getUserListsUseCaseProvider = Provider(
  (ref) => GetUserListsUseCase(ref.read(itemRepositoryProvider)),
);

// 3. Provedor do Controller (Injeta o Use Case e a função de invalidação)
final listControllerProvider = StateNotifierProvider<ListController, ListState>(
  (ref) => ListController(
    getUserListsUseCase: ref.read(getUserListsUseCaseProvider),
    // 🚨 CORREÇÃO CRÍTICA: Passamos a função invalidate de forma segura
    onInvalidate: () {
      // Invalida o provedor que a Home Page usa
      ref.invalidate(getLatestListProvider);
    },
  ),
);
