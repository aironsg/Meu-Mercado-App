// lib/features/lists/presentation/controller/list_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/foundation.dart';

import 'package:meu_mercado/features/lists/domain/usecases/get_user_lists_usecase.dart';
import 'package:meu_mercado/features/lists/domain/usecases/update_item_in_list_usecase.dart';
// 🚨 NOVO
import 'package:meu_mercado/features/lists/domain/usecases/delete_item_from_list_usecase.dart';
import 'package:meu_mercado/features/lists/domain/usecases/delete_list_usecase.dart';
// 🚨 FIM NOVO
import 'package:meu_mercado/features/lists/presentation/state/list_state.dart';
import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';
// Importa o provider do repositório para o updateItemInListUseCaseProvider
import 'package:meu_mercado/features/lists/presentation/provider/lists_provider.dart';

final updateItemInListUseCaseProvider = Provider(
  (ref) => UpdateItemInListUseCase(ref.read(itemRepositoryProvider)),
);

class ListController extends StateNotifier<ListState> {
  final GetUserListsUseCase _getUserListsUseCase;
  final UpdateItemInListUseCase _updateItemInListUseCase;
  final DeleteItemFromListUseCase _deleteItemFromListUseCase; // NOVO
  final DeleteListUseCase _deleteListUseCase; // NOVO
  final VoidCallback _onInvalidate;

  ListController({
    required GetUserListsUseCase getUserListsUseCase,
    required UpdateItemInListUseCase updateItemInListUseCase,
    required DeleteItemFromListUseCase deleteItemFromListUseCase,
    required DeleteListUseCase deleteListUseCase,
    required VoidCallback onInvalidate,
  }) : _getUserListsUseCase = getUserListsUseCase,
       _updateItemInListUseCase = updateItemInListUseCase,
       _deleteItemFromListUseCase = deleteItemFromListUseCase,
       _deleteListUseCase = deleteListUseCase,
       _onInvalidate = onInvalidate,
       super(ListState());

  Future<void> loadLists() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final lists = await _getUserListsUseCase.execute();
      state = state.copyWith(lists: lists, loading: false);
      _onInvalidate();
    } catch (e) {
      state = state.copyWith(
        error: 'Falha ao carregar listas.',
        loading: false,
      );
    }
  }

  /// 🚨 NOVO/ATUALIZADO: Salva (Adiciona ou Edita) um item específico.
  Future<bool> saveItemInHistoryList({
    required String listId,
    required ItemEntity itemToSave,
  }) async {
    state = state.copyWith(loading: true, error: null);

    try {
      // O Use Case (e o Repositório) agora lidam com a lógica de ADD ou UPDATE
      await _updateItemInListUseCase.execute(
        listId: listId,
        updatedItem: itemToSave,
      );

      // Sucesso: Recarrega as listas do servidor para refletir a mudança
      await loadLists();
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar item: $e');
      state = state.copyWith(
        error: 'Falha ao salvar item: ${e.toString()}',
        loading: false,
      );
      return false;
    }
  }

  // Mantém o método antigo para compatibilidade do ListPage/ItemCard, agora usando a nova lógica
  Future<bool> updateItemInHistoryList({
    required String listId,
    required ItemEntity updatedItem,
  }) async {
    return saveItemInHistoryList(listId: listId, itemToSave: updatedItem);
  }

  /// 🚨 NOVO: Remove um item do histórico (Lista)
  Future<bool> removeItemFromHistoryList({
    required String listId,
    required String itemId,
  }) async {
    state = state.copyWith(loading: true, error: null);

    try {
      await _deleteItemFromListUseCase.execute(listId: listId, itemId: itemId);

      await loadLists(); // Recarrega as listas
      return true;
    } catch (e) {
      debugPrint('Erro ao remover item: $e');
      state = state.copyWith(
        error: 'Falha ao remover item: ${e.toString()}',
        loading: false,
      );
      return false;
    }
  }

  /// 🚨 NOVO: Exclui uma lista completa
  Future<bool> deleteShoppingList(String listId) async {
    state = state.copyWith(loading: true, error: null);

    try {
      await _deleteListUseCase.execute(listId);

      await loadLists(); // Recarrega as listas
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar lista: $e');
      state = state.copyWith(
        error: 'Falha ao deletar lista: ${e.toString()}',
        loading: false,
      );
      return false;
    }
  }

  void navigateToItemEdit(Map<String, dynamic> itemData) {
    Modular.to.navigate('/item', arguments: itemData);
  }
}
