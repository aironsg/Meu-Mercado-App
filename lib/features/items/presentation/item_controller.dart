import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/entities/item_entity.dart';
import '../domain/repositories/item_repository.dart'; // NOVO: Para tipar o Repositório
import '../domain/usecases/get_previous_items_usecase.dart';
import '../data/repositories/item_repository_impl.dart'; // Import da implementação
import '../presentation/state/item_state.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepositoryImpl();
});

// Provedor do Use Case (Depende do Repositório)
final getPreviousItemsUseCaseProvider = Provider(
  (ref) => GetPreviousItemsUseCase(ref.read(itemRepositoryProvider)),
);

// Provedor do Controller (Depende do Repositório e do Use Case)
final itemControllerProvider = StateNotifierProvider<ItemController, ItemState>(
  (ref) => ItemController(
    repository: ref.read(itemRepositoryProvider),
    getPreviousItemsUseCase: ref.read(getPreviousItemsUseCaseProvider),
  ),
);

// ==========================================================
// 2. CONTROLLER (Lógica de Edição e Listas)
// ==========================================================

class ItemController extends StateNotifier<ItemState> {
  final ItemRepository _repository;
  final GetPreviousItemsUseCase _getPreviousItemsUseCase;

  ItemController({
    required ItemRepository repository,
    required GetPreviousItemsUseCase getPreviousItemsUseCase,
  }) : _repository = repository,
       _getPreviousItemsUseCase = getPreviousItemsUseCase,
       super(ItemState());

  // MÉTODO CHAVE: Atualiza um item existente na lista temporária (Edição)
  void updateItemInEditingList(ItemEntity updatedItem) {
    // Itera sobre a lista de itens de edição
    final updatedList = state.editingItems.map((item) {
      // Se o ID for igual, substitui pelo item atualizado
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();

    // Atualiza o estado da lista
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

      // Payload que será salvo no Repositório
      final shoppingListPayload = {
        'userId': user.uid,
        'date': DateTime.now().toIso8601String(),
        'items': state.editingItems.map((e) => e.toMap()).toList(),
      };

      await _repository.saveList(shoppingListPayload);

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
      // 1. Busca itens da categoria e mês anterior via Use Case
      final previousItems = await _getPreviousItemsUseCase.execute(category);

      // 2. Sobrescreve a lista atual com os itens da lista anterior
      state = state.copyWith(editingItems: previousItems, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}
