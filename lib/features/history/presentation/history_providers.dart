import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_mercado/features/history/domain/get_stats_usecase.dart';
import 'package:meu_mercado/features/items/data/repositories/item_repository_impl.dart';
import 'package:meu_mercado/features/items/domain/repositories/item_repository.dart';

// Reutiliza o provedor de repositório da feature 'items'
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepositoryImpl();
});

// Provedor do Use Case de Estatísticas
final getStatsUseCaseProvider = Provider(
  (ref) => GetStatsUseCase(ref.read(itemRepositoryProvider)),
);

// Provedor assíncrono para os dados de estatísticas (consumido pela HistoryPage)
final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return await useCase.execute();
});
