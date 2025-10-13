import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/foundation.dart';
import 'package:meu_mercado/features/history/presentation/history_providers.dart';
import 'package:meu_mercado/features/lists/domain/usecases/get_user_lists_usecase.dart';
import 'package:meu_mercado/features/lists/domain/usecases/update_item_in_list_usecase.dart';
import 'package:meu_mercado/features/lists/presentation/state/list_state.dart';
import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';

final updateItemInListUseCaseProvider = Provider(
  (ref) => UpdateItemInListUseCase(ref.read(itemRepositoryProvider)),
);

class ListController extends StateNotifier<ListState> {
  final GetUserListsUseCase _getUserListsUseCase;
  final UpdateItemInListUseCase _updateItemInListUseCase; // NOVO
  final VoidCallback _onInvalidate;

  ListController({
    required GetUserListsUseCase getUserListsUseCase,
    required UpdateItemInListUseCase
    updateItemInListUseCase, // Recebe novo Use Case
    required VoidCallback onInvalidate,
  }) : _getUserListsUseCase = getUserListsUseCase,
       _updateItemInListUseCase = updateItemInListUseCase,
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

  /// 🚨 NOVO MÉTODO: Atualiza o item no servidor e recarrega as listas.
  Future<bool> updateItemInHistoryList({
    required String listId,
    required ItemEntity updatedItem,
  }) async {
    final originalError = state.error;
    state = state.copyWith(loading: true, error: null);

    try {
      await _updateItemInListUseCase.execute(
        listId: listId,
        updatedItem: updatedItem,
      );

      // Sucesso: Recarrega as listas do servidor para refletir a mudança
      await loadLists();
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar item: $e');
      // Restaura o erro original se a recarga tiver limpado ele.
      state = state.copyWith(
        error: 'Falha ao salvar item: ${e.toString()}',
        loading: false,
      );
      return false;
    }
  }

  void navigateToItemEdit(Map<String, dynamic> itemData) {
    Modular.to.navigate('/item', arguments: itemData);
  }
}
