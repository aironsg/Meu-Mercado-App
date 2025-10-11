import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/foundation.dart';
import 'package:meu_mercado/features/lists/domain/usecases/get_user_lists_usecase.dart';
import 'package:meu_mercado/features/lists/presentation/state/list_state.dart';

class ListController extends StateNotifier<ListState> {
  final GetUserListsUseCase _getUserListsUseCase;
  final VoidCallback
  _onInvalidate; // 🚨 CORREÇÃO: Recebe a função de invalidação

  ListController({
    required GetUserListsUseCase getUserListsUseCase,
    required VoidCallback onInvalidate, // Recebe a função de invalidate
  }) : _getUserListsUseCase = getUserListsUseCase,
       _onInvalidate = onInvalidate,
       super(ListState()) {
    loadLists();
  }

  Future<void> loadLists() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final lists = await _getUserListsUseCase.execute();
      state = state.copyWith(lists: lists, loading: false);

      // 🚨 CORREÇÃO: Chama a função injetada para invalidar o provedor da Home Page.
      _onInvalidate();
    } catch (e) {
      debugPrint('Erro no ListController.loadLists: $e');
      state = state.copyWith(
        error: 'Falha ao carregar listas.',
        loading: false,
      );
    }
  }

  /// Navega para a página ItemPage para editar um item específico de uma lista.
  void navigateToItemEdit(Map<String, dynamic> itemData) {
    Modular.to.navigate('/item', arguments: itemData);
  }
}
