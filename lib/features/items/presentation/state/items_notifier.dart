import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/items_repository.dart';

final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  throw UnimplementedError(); // será registrado no DI
});

final itemsNotifierProvider =
    StateNotifierProvider<ItemsNotifier, AsyncValue<List<ItemEntity>>>((ref) {
      final repo = ref.watch(itemsRepositoryProvider);
      return ItemsNotifier(repo)..load();
    });

class ItemsNotifier extends StateNotifier<AsyncValue<List<ItemEntity>>> {
  final ItemsRepository repository;
  late final Stream<List<ItemEntity>> _stream;
  ItemsNotifier(this.repository) : super(const AsyncValue.loading());

  void load() {
    _stream = repository.watchItems();
    _stream.listen(
      (items) {
        state = AsyncValue.data(items);
      },
      onError: (err, st) {
        state = AsyncValue.error(err, st);
      },
    );
  }

  Future<void> addItem(ItemEntity item) async {
    await repository.addItem(item);
  }

  Future<void> updateItem(ItemEntity item) async {
    await repository.updateItem(item);
  }

  Future<void> deleteItem(int id) async {
    await repository.deleteItem(id);
  }
}
