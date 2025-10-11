import '../../domain/entities/item_entity.dart';

class ItemState {
  final List<ItemEntity> items;
  final bool loading;
  final String? error;

  ItemState({this.items = const [], this.loading = false, this.error});

  ItemState copyWith({List<ItemEntity>? items, bool? loading, String? error}) {
    return ItemState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
