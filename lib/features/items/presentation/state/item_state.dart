import '../../domain/entities/item_entity.dart';

class ItemState {
  final List<ItemEntity> editingItems; // Lista de itens temporária (em edição)
  final bool loading;
  final String? error;

  ItemState({this.editingItems = const [], this.loading = false, this.error});

  // Método copyWith para atualizar o estado de forma imutável
  ItemState copyWith({
    List<ItemEntity>? editingItems,
    bool? loading,
    String? error,
  }) {
    return ItemState(
      editingItems: editingItems ?? this.editingItems,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}
