import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meu_mercado/features/lists/presentation/provider/lists_provider.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/usecases/get_previous_items_usecase.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../../home/presentation/provider/home_page_provider.dart'; // Para invalidar
import '../state/item_state.dart';

// Provedores de injeção... (Mantidos)
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepositoryImpl();
});

final getPreviousItemsUseCaseProvider = Provider(
  (ref) => GetPreviousItemsUseCase(ref.read(itemRepositoryProvider)),
);

// NOVO: Adiciona a injeção do ref.invalidate para ser passado para o Controller
final itemControllerProvider = StateNotifierProvider<ItemController, ItemState>(
  (ref) => ItemController(
    repository: ref.read(itemRepositoryProvider),
    getPreviousItemsUseCase: ref.read(getPreviousItemsUseCaseProvider),
    // Injetamos a função invalidate para o Controller usar, corrigindo o erro.
    onInvalidate: () {
      ref.invalidate(getLatestListProvider);
      ref.invalidate(
        listControllerProvider,
      ); // Invalida a lista completa também
    },
  ),
);

// ==========================================================
// 2. CONTROLLER (Lógica de Edição e Listas)
// ==========================================================

class ItemController extends StateNotifier<ItemState> {
  final ItemRepository _repository;
  final GetPreviousItemsUseCase _getPreviousItemsUseCase;
  final VoidCallback _onInvalidate; // Função para invalidar Providers

  ItemController({
    required ItemRepository repository,
    required GetPreviousItemsUseCase getPreviousItemsUseCase,
    required VoidCallback onInvalidate,
  }) : _repository = repository,
       _getPreviousItemsUseCase = getPreviousItemsUseCase,
       _onInvalidate = onInvalidate,
       super(ItemState());

  // MÉTODO CHAVE: Atualiza um item existente na lista temporária (Edição)
  void updateItemInEditingList(ItemEntity updatedItem) {
    final updatedList = state.editingItems.map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();

    state = state.copyWith(editingItems: updatedList);
  }

  // Adicionar item à lista temporária (Adição)
  void addItemToEditingList(ItemEntity item) {
    final updatedList = [...state.editingItems, item];
    state = state.copyWith(editingItems: updatedList);
  }

  // Remove item da lista temporária
  void removeItemFromEditingList(String itemId) {
    final updatedList = state.editingItems
        .where((item) => item.id != itemId)
        .toList();
    state = state.copyWith(editingItems: updatedList);
  }

  // Limpa a lista temporária (Botão "Nova Lista")
  void resetList() {
    state = state.copyWith(editingItems: []);
  }

  // FLUXO: Cadastrar a lista completa no banco de dados com a data
  Future<void> registerList() async {
    if (state.editingItems.isEmpty) return;

    state = state.copyWith(loading: true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      final shoppingListPayload = {
        'userId': user.uid,
        'date': DateTime.now().toIso8601String(),
        'items': state.editingItems.map((e) => e.toMap()).toList(),
      };

      await _repository.saveList(shoppingListPayload);

      // 🚨 CRÍTICO: Invalida os provedores de leitura (Home Page e List Page)
      _onInvalidate();

      // Limpa a lista de edição após o sucesso
      state = state.copyWith(editingItems: [], loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  // Lógica para carregar itens da lista anterior
  Future<void> loadPreviousItems(String category) async {
    state = state.copyWith(loading: true);
    try {
      final previousItems = await _getPreviousItemsUseCase.execute(category);
      state = state.copyWith(editingItems: previousItems, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}
