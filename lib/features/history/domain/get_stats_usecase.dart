import 'package:intl/intl.dart';
import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';
import 'package:meu_mercado/features/items/domain/repositories/item_repository.dart';

/// Define o formato da métrica de item mais caro ou de maior impacto no gasto.
class ItemStat {
  final String name;
  final String category;
  final double value;
  final double quantity;

  ItemStat({
    required this.name,
    required this.category,
    required this.value,
    required this.quantity,
  });
}

/// Define o formato da métrica de gasto mensal.
class MonthlyExpense {
  final String monthYear;
  final double total;

  MonthlyExpense({required this.monthYear, required this.total});
}

class GetStatsUseCase {
  final ItemRepository repository;

  GetStatsUseCase(this.repository);

  /// Executa toda a lógica de processamento de dados.
  Future<Map<String, dynamic>> execute() async {
    final lists = await repository.getUserLists();

    if (lists.isEmpty) {
      return {
        'expensiveItems': [],
        'categoryDistribution': {},
        'resourceHogs': [],
        'monthlyExpenses': [],
      };
    }

    // 1. Coleta e Normaliza todos os itens de todas as listas
    final allItems = lists
        .expand((list) => list['items'] as List<ItemEntity>)
        .toList();

    // 2. Filtra por Preço (Mais caros por unidade)
    final expensiveItems = allItems.toList()
      ..sort((a, b) => b.price.compareTo(a.price));

    final topExpensiveItems = expensiveItems
        .map(
          (i) => ItemStat(
            name: i.name,
            category: i.category,
            value: i.price,
            quantity: i.quantity.toDouble(),
          ),
        )
        .take(5) // Top 5
        .toList();

    // 3. Distribuição por Categoria
    final Map<String, double> categoryMap = {};
    for (var item in allItems) {
      categoryMap[item.category] =
          (categoryMap[item.category] ?? 0) + (item.price * item.quantity);
    }

    // 4. Itens com Maior Impacto no Gasto (Item mais gastador)
    final Map<String, double> hogMap = {};
    for (var item in allItems) {
      final key = item.name;
      hogMap[key] = (hogMap[key] ?? 0) + (item.price * item.quantity);
    }
    final resourceHogs =
        hogMap.entries
            .map(
              (e) => ItemStat(
                name: e.key,
                category: allItems.firstWhere((i) => i.name == e.key).category,
                value: e.value,
                quantity: 0, // Não aplicável para este cálculo agregado
              ),
            )
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final topHogs = resourceHogs.take(5).toList();

    // 5. Gasto por Mês
    final Map<String, double> monthlyMap = {};
    for (var list in lists) {
      final DateTime? date = list['createdAt'] as DateTime?;
      if (date == null) continue;

      final monthYear = DateFormat('MM/yyyy').format(date);
      final listTotal = (list['items'] as List<ItemEntity>).fold(
        0.0,
        (sum, item) => sum + item.price * item.quantity,
      );

      monthlyMap[monthYear] = (monthlyMap[monthYear] ?? 0) + listTotal;
    }

    final monthlyExpenses =
        monthlyMap.entries
            .map((e) => MonthlyExpense(monthYear: e.key, total: e.value))
            .toList()
          ..sort((a, b) => a.monthYear.compareTo(b.monthYear));

    return {
      'expensiveItems': topExpensiveItems,
      'categoryDistribution': categoryMap,
      'resourceHogs': topHogs,
      'monthlyExpenses': monthlyExpenses,
    };
  }
}
