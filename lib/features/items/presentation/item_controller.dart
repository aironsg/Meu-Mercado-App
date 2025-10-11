import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/item_repository_impl.dart';
import '../domain/entities/item_entity.dart';
import '../domain/usecases/add_item_usecase.dart';
import '../presentation/state/item_state.dart';

final itemControllerProvider = StateNotifierProvider<ItemController, ItemState>(
  (ref) => ItemController(),
);

class ItemController extends StateNotifier<ItemState> {
  final _useCase = AddItemUseCase(ItemRepositoryImpl());

  ItemController() : super(ItemState());

  Future<void> addItem(ItemEntity item) async {
    state = state.copyWith(loading: true);
    try {
      await _useCase.execute(item);
      final updatedList = [...state.items, item];
      state = state.copyWith(items: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}
