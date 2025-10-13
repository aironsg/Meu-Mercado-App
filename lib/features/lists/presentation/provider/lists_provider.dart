import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_mercado/features/history/presentation/history_providers.dart';
import 'package:meu_mercado/features/home/presentation/provider/home_page_provider.dart';
import 'package:meu_mercado/features/items/data/repositories/item_repository_impl.dart';
import 'package:meu_mercado/features/items/domain/repositories/item_repository.dart';
import 'package:meu_mercado/features/lists/data/datasources/list_datasource.dart';
import 'package:meu_mercado/features/lists/data/list_repository_impl.dart';

import 'package:meu_mercado/features/lists/domain/repositories/list_repository.dart';
import 'package:meu_mercado/features/lists/domain/usecases/get_user_lists_usecase.dart';
import 'package:meu_mercado/features/lists/domain/usecases/update_item_in_list_usecase.dart';
import 'package:meu_mercado/features/lists/presentation/controller/list_controller.dart';
import '../state/list_state.dart';

// 1. Provedor do Repositório (Base: ItemRepository, pois ele contém os métodos de lista)
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  // Retorna a implementação concreta do ItemRepository
  return ItemRepositoryImpl();
});

// 2. Provedor do Use Case para buscar todas as listas
final getUserListsUseCaseProvider = Provider(
  (ref) => GetUserListsUseCase(ref.read(itemRepositoryProvider)),
);

// 3. Provedor do Use Case para atualização de item no histórico
final updateItemInListUseCaseProvider = Provider(
  (ref) => UpdateItemInListUseCase(ref.read(itemRepositoryProvider)),
);

// ==========================================================
// 2. PROVEDOR PRINCIPAL (CONTROLLER)
// ==========================================================

final listControllerProvider = StateNotifierProvider<ListController, ListState>(
  (ref) => ListController(
    getUserListsUseCase: ref.read(getUserListsUseCaseProvider),
    // ✅ CORREÇÃO CRÍTICA: Injeta a instância do Use Case de atualização
    updateItemInListUseCase: ref.read(updateItemInListUseCaseProvider),
    onInvalidate: () {
      // Invalida o provedor da Home Page para forçar o reload da última lista
      ref.invalidate(getLatestListProvider);
      ref.invalidate(statsProvider);
    },
  ),
);
