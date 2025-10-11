import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_mercado/features/history/domain/get_stats_usecase.dart';
import 'package:meu_mercado/features/history/presentation/history_providers.dart';
import '../../../../core/theme/app_colors.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Compras'),
        backgroundColor: AppColors.primary,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Erro ao carregar estatísticas. Tente novamente.\n${e.toString()}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (stats) {
          final List<ItemStat> resourceHogs =
              stats['resourceHogs'] as List<ItemStat>;
          final Map<String, double> categoryDistribution =
              stats['categoryDistribution'] as Map<String, double>;
          final List<MonthlyExpense> monthlyExpenses =
              stats['monthlyExpenses'] as List<MonthlyExpense>;

          return RefreshIndicator(
            onRefresh: () => ref.refresh(statsProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCardTitle('Visão Geral dos Gastos'),
                _buildMonthlyExpenseChart(monthlyExpenses),

                _buildCardTitle('Itens que Mais Consomem (Custo Total)'),
                _buildResourceHogsList(resourceHogs),

                _buildCardTitle('Distribuição por Categoria'),
                _buildCategoryPieChart(categoryDistribution),

                _buildCardTitle('Itens Mais Caros (Preço Unitário)'),
                _buildExpensiveItemsList(
                  stats['expensiveItems'] as List<ItemStat>,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widgets de Gráficos e Listas ---

  Widget _buildCardTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // 1. Gráfico de Gasto por Mês (Gráfico de Barras Simulado)
  Widget _buildMonthlyExpenseChart(List<MonthlyExpense> data) {
    if (data.isEmpty)
      return const Text('Dados insuficientes para gasto mensal.');

    final maxTotal = data.map((e) => e.total).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: data.map((item) {
            final barHeight = (item.total / maxTotal) * 150;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      item.monthYear,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 20,
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: double.infinity,
                      child: FractionallySizedBox(
                        widthFactor:
                            item.total /
                            maxTotal, // Simula o preenchimento da barra
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'R\$ ${item.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 2. Distribuição por Categoria (Gráfico de Pizza Simulado - Lista)
  Widget _buildCategoryPieChart(Map<String, double> data) {
    if (data.isEmpty)
      return const Text('Dados insuficientes para distribuição de categorias.');

    final total = data.values.reduce((a, b) => a + b);
    final sortedData = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      child: Column(
        children: sortedData.map((entry) {
          final percentage = (entry.value / total) * 100;
          return ListTile(
            title: Text('${entry.key}'),
            trailing: Text(
              '${percentage.toStringAsFixed(1)}% (R\$ ${entry.value.toStringAsFixed(2)})',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 3. Itens com Maior Impacto no Gasto (Itens mais "gastadores")
  Widget _buildResourceHogsList(List<ItemStat> data) {
    if (data.isEmpty)
      return const Text('Dados insuficientes para itens de maior impacto.');

    return Card(
      elevation: 4,
      child: Column(
        children: data.map((item) {
          return ListTile(
            leading: const Icon(Icons.trending_up, color: Colors.orange),
            title: Text('${item.name} (${item.category})'),
            subtitle: Text('Custo Total: R\$ ${item.value.toStringAsFixed(2)}'),
          );
        }).toList(),
      ),
    );
  }

  // 4. Itens Mais Caros (Preço Unitário)
  Widget _buildExpensiveItemsList(List<ItemStat> data) {
    if (data.isEmpty)
      return const Text('Nenhum item com preço unitário registrado.');

    // Filtramos apenas os que têm preço para garantir relevância
    final relevantItems = data.where((i) => i.value > 0).take(5).toList();

    return Card(
      elevation: 4,
      child: Column(
        children: relevantItems.map((item) {
          return ListTile(
            leading: const Icon(Icons.attach_money, color: Colors.red),
            title: Text('${item.name}'),
            subtitle: Text(
              'Preço Unitário: R\$ ${item.value.toStringAsFixed(2)}',
            ),
            trailing: Text(item.category),
          );
        }).toList(),
      ),
    );
  }
}
