// lib/features/history/presentation/pages/history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_mercado/features/history/domain/get_stats_usecase.dart';
import 'package:meu_mercado/features/history/presentation/history_providers.dart';
import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';
import 'dart:math';
import '../../../../core/theme/app_colors.dart';
// 🚨 NOVO: Importa o widget de background reutilizável
import '../../../../core/widgets/app_background.dart';
// Imports para PDF e Compartilhamento (MANTIDOS)
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String? _selectedMonth1;
  String? _selectedMonth2;
  // 🚨 NOVO: Filtro de categoria para a comparação
  String? _selectedCategory;
  Map<String, List<ItemEntity>> _comparisonData = {};

  final Map<String, Color> categoryColors = {};

  // 🚨 NOVO: Lista de categorias disponíveis (deve ser a mesma do ItemPage)
  final List<String> _categories = [
    'MERCADO',
    'FEIRA',
    'ROUPAS',
    'CASA',
    'GERAIS',
  ];

  Color _getColorForCategory(String category) {
    if (!categoryColors.containsKey(category)) {
      final colorList = [
        Colors.red.shade400,
        Colors.blue.shade400,
        Colors.green.shade400,
        Colors.orange.shade400,
        Colors.purple.shade400,
        Colors.teal.shade400,
      ];
      categoryColors[category] =
          colorList[categoryColors.length % colorList.length];
    }
    return categoryColors[category]!;
  }

  // Função auxiliar para formatar o rótulo do mês (Ex: Out\n2025)
  String _formatMonthLabel(String monthYear) {
    // Input: MM/yyyy (e.g., 10/2025)
    try {
      final month = int.parse(monthYear.substring(0, 2));
      final year = monthYear.substring(3);
      final monthNames = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ];
      return '${monthNames[month - 1]}\n$year';
    } catch (e) {
      return monthYear;
    }
  }

  // Novo método para buscar dados para a comparação (Mês 1 e Mês 2)
  Future<void> _runComparison(List<Map<String, dynamic>> allLists) async {
    // 🚨 ATUALIZADO: A comparação agora requer a categoria
    if (_selectedMonth1 == null ||
        _selectedMonth2 == null ||
        _selectedCategory == null)
      return;

    final filterCategory = _selectedCategory;

    // Converte a data da lista (Timestamp/DateTime) para o formato 'MM/yyyy'
    String _getMonthYear(Map<String, dynamic> list) {
      final DateTime? date = list['createdAt'] as DateTime?;
      return date != null
          ? '${date.month.toString().padLeft(2, '0')}/${date.year}'
          : '';
    }

    // Função auxiliar para filtrar itens pela categoria selecionada
    List<ItemEntity> _filterItemsByCategory(Map<String, dynamic> list) {
      final items = (list['items'] as List<ItemEntity>?) ?? [];
      return items.where((item) => item.category == filterCategory).toList();
    }

    // Busca a lista completa (com itens) para o Mês 1
    final list1 = allLists.firstWhere(
      (list) => _getMonthYear(list) == _selectedMonth1,
      orElse: () => {},
    );

    // Busca a lista completa (com itens) para o Mês 2
    final list2 = allLists.firstWhere(
      (list) => _getMonthYear(list) == _selectedMonth2,
      orElse: () => {},
    );

    setState(() {
      // 🚨 ATUALIZADO: Filtra os itens da lista 1 e 2 pela categoria
      _comparisonData = {
        _selectedMonth1!: _filterItemsByCategory(list1),
        _selectedMonth2!: _filterItemsByCategory(list2),
      };
    });
  }

  // Geração real do PDF (MANTIDO)
  Future<Uint8List> _generateComparisonPdf(
    List<Map<String, dynamic>> relevantItems,
    String month1,
    String month2,
  ) async {
    final pdf = pw.Document();

    // Dados para a tabela PDF
    final tableHeaders = ['Item', '$month1 (R\$)', '$month2 (R\$)', 'Variação'];

    final tableData = relevantItems.map((item) {
      final price1 = item[month1] as double;
      final price2 = item[month2] as double;
      final name = item['name'] as String;

      String variationText = 'N/A';
      if (price1 > 0 && price2 > 0) {
        final diff = price2 - price1;
        final percentage = (diff / price1) * 100;

        String sign = diff >= 0 ? '+' : '';
        variationText =
            '${sign}R\$${diff.toStringAsFixed(2)}\n(${percentage.toStringAsFixed(1)}%)';
      } else if (price1 > 0) {
        variationText = 'Ausente em $month2';
      } else if (price2 > 0) {
        variationText = 'Novo em $month2';
      }

      return [
        name,
        price1.toStringAsFixed(2),
        price2.toStringAsFixed(2),
        variationText,
      ];
    }).toList();

    // Adiciona o conteúdo ao PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Relatório de Comparação de Preços (Categoria: $_selectedCategory)',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Período: $month1 vs $month2'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: tableHeaders,
                data: tableData,
                border: pw.TableBorder.all(
                  color: PdfColors.grey500,
                  width: 0.5,
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue700,
                ),
                cellAlignment: pw.Alignment.centerRight,
                columnWidths: {
                  0: const pw.FlexColumnWidth(3), // Item Name
                  1: const pw.FlexColumnWidth(1.5), // Price 1
                  2: const pw.FlexColumnWidth(1.5), // Price 2
                  3: const pw.FlexColumnWidth(2), // Variation
                },
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Exportação e Compartilhamento (MANTIDO)
  Future<void> _exportComparisonToPdf(
    List<Map<String, dynamic>> relevantItems,
    String month1,
    String month2,
  ) async {
    try {
      final pdfBytes = await _generateComparisonPdf(
        relevantItems,
        month1,
        month2,
      );

      final output = await getTemporaryDirectory();
      final filePath =
          '${output.path}/comparativo_${month1.replaceAll('/', '-')}_vs_${month2.replaceAll('/', '-')}_$_selectedCategory.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text:
            'Comparativo de Preços Meu Mercado ($month1 vs $month2 - $_selectedCategory)',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório PDF compartilhado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar/compartilhar PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      // 🚨 UX/UI: Fundo transparente para o AppBackground
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Análise de Compras'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Modular.to.navigate("/home"),
        ),
      ),
      // 🚨 UX/UI: Aplica o AppBackground
      body: AppBackground(
        child: statsAsync.when(
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
            final List<Map<String, dynamic>> allLists =
                stats['allLists'] as List<Map<String, dynamic>>? ?? [];

            // Obtém a lista de meses únicos no formato 'MM/yyyy'
            final List<String> availableMonths = monthlyExpenses
                .map((e) => e.monthYear)
                .toSet()
                .toList();
            availableMonths.sort();

            // Inicializa os meses de comparação
            if (_selectedMonth1 == null && availableMonths.isNotEmpty) {
              _selectedMonth1 =
                  availableMonths.last; // Mês atual ou mais recente
            }
            if (_selectedMonth2 == null && availableMonths.length > 1) {
              _selectedMonth2 =
                  availableMonths[availableMonths.length - 2]; // Mês anterior
            } else if (_selectedMonth2 == null && availableMonths.isNotEmpty) {
              _selectedMonth2 = availableMonths.first;
            }
            // Inicializa a categoria
            if (_selectedCategory == null) {
              _selectedCategory = _categories.first;
            }

            return RefreshIndicator(
              onRefresh: () => ref.refresh(statsProvider.future),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCardTitle('Gastos Totais'),
                  _buildMonthlyExpenseChart(monthlyExpenses),

                  _buildCardTitle('Distribuição por Categoria'),
                  _buildCategoryPieChart(categoryDistribution),

                  _buildCardTitle('Itens que Mais Consomem (Custo Total)'),
                  _buildResourceHogsList(resourceHogs),

                  _buildCardTitle('Itens Mais Caros (Preço Unitário)'),
                  _buildExpensiveItemsList(
                    stats['expensiveItems'] as List<ItemStat>,
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.primary, thickness: 2),
                  _buildCardTitle('Comparativo de Preços Mês a Mês'),
                  // 🚨 ATUALIZADO: Passa as listas de meses e a lista de dados
                  _buildComparisonControls(availableMonths, allLists),

                  if (_comparisonData.isNotEmpty)
                    _buildComparisonResults(
                      _comparisonData,
                      _selectedMonth1!,
                      _selectedMonth2!,
                    ),

                  // 🚨 UX/UI: Espaçamento de segurança no final do ListView
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 16.0,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Widgets de Gráficos e Listas (MANTIDOS) ---

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

  // 1. Gráfico de Gasto por Mês (Gráfico de Barras Vertical)
  Widget _buildMonthlyExpenseChart(List<MonthlyExpense> data) {
    if (data.isEmpty)
      return const Text('Dados insuficientes para gasto mensal.');

    // 1. Limitar aos últimos 24 meses (mais recentes)
    final recentData = data.length > 24 ? data.sublist(data.length - 24) : data;

    // 2. Encontrar o valor máximo para dimensionar as barras
    final maxTotal = recentData.map((e) => e.total).reduce(max);

    // Define a altura total do contêiner do gráfico
    const double chartMaxHeight = 200.0;
    const double textLabelHeight = 14.0;
    const double spacingHeight = 4.0;
    const double fixedOverhead = textLabelHeight + spacingHeight;
    const double availableBarHeight = chartMaxHeight - fixedOverhead;

    const double barWidth = 50.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Valor máximo do eixo Y
            Text(
              'R\$ ${maxTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // Gráfico (Barras e Valores)
            SizedBox(
              height: chartMaxHeight,
              // Permite rolagem lateral
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.end, // Alinha as barras pela base
                  children: recentData.map((item) {
                    final barHeight = item.total > 0
                        ? (item.total / maxTotal) * availableBarHeight
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Valor acima da barra
                          if (item.total > 0)
                            Text(
                              'R\$ ${item.total.toStringAsFixed(0)}', // Arredonda para exibição
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          const SizedBox(height: 4),
                          // A Barra
                          Container(
                            width: barWidth - 8, // Subtrai o padding horizontal
                            height: barHeight,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.purple500, // Cor primária do tema
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            // Eixo X (rótulos)
            SizedBox(
              height: 36, // Altura fixa para os rótulos
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: recentData.map((item) {
                    return SizedBox(
                      width: barWidth,
                      child: Text(
                        _formatMonthLabel(item.monthYear),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Distribuição por Categoria (Gráfico de Pizza Simulado - NOVO VISUAL)
  Widget _buildCategoryPieChart(Map<String, double> data) {
    final Map<String, double> allCategories = {
      'MERCADO': 0.0,
      'FEIRA': 0.0,
      'ROUPAS': 0.0,
      'CASA': 0.0,
      'GERAIS': 0.0,
      ...data,
    };

    final total = allCategories.values.reduce((a, b) => a + b);
    if (total == 0) return const Text('Nenhum gasto registrado.');

    final sortedEntries = allCategories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simulação de Gráfico de Pizza
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipOval(
                child: Stack(children: _buildPieSlices(sortedEntries, total)),
              ),
            ),
            const SizedBox(width: 16),
            // Legenda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sortedEntries.map((entry) {
                  final percentage = (entry.value / total) * 100;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: _getColorForCategory(entry.key),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            // Mostra 0% se o gasto for 0
                            '${entry.key}: ${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ajuda a construir as fatias do gráfico de pizza simulado
  List<Widget> _buildPieSlices(
    List<MapEntry<String, double>> entries,
    double total,
  ) {
    double startAngle = -pi / 2; // Começa de cima (12 horas)
    List<Widget> slices = [];

    for (var entry in entries) {
      final sweepAngle = (entry.value / total) * 2 * pi;

      if (entry.value > 0) {
        slices.add(
          CustomPaint(
            painter: _PieSlicePainter(
              color: _getColorForCategory(entry.key),
              startAngle: startAngle,
              sweepAngle: sweepAngle,
            ),
            size: const Size(120, 120),
          ),
        );
      }
      startAngle += sweepAngle;
    }
    return slices;
  }

  // 3. Itens com Maior Impacto no Gasto (Itens mais "gastadores") - COM ROLAGEM
  Widget _buildResourceHogsList(List<ItemStat> data) {
    if (data.isEmpty)
      return const Text('Dados insuficientes para itens de maior impacto.');

    return Card(
      elevation: 4,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300.0),
        child: SingleChildScrollView(
          child: Column(
            children: data.map((item) {
              return ListTile(
                leading: const Icon(Icons.trending_up, color: Colors.orange),
                title: Text('${item.name} (${item.category})'),
                subtitle: Text(
                  'Custo Total: R\$ ${item.value.toStringAsFixed(2)}',
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // 4. Itens Mais Caros (Preço Unitário) - COM ROLAGEM
  Widget _buildExpensiveItemsList(List<ItemStat> data) {
    if (data.isEmpty)
      return const Text('Nenhum item com preço unitário registrado.');

    final allRelevantItems = data.where((i) => i.value > 0).toList();

    return Card(
      elevation: 4,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300.0),
        child: SingleChildScrollView(
          child: Column(
            children: allRelevantItems.map((item) {
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
        ),
      ),
    );
  }

  // --- Implementação do Comparativo de Preços ---
  Widget _buildComparisonControls(
    List<String> availableMonths,
    List<Map<String, dynamic>> allLists,
  ) {
    // Flag para desabilitar o botão de comparação se faltar seleção
    final bool isComparisonEnabled =
        (_selectedMonth1 != null &&
        _selectedMonth2 != null &&
        _selectedMonth1 != _selectedMonth2 &&
        _selectedCategory != null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // 🚨 NOVO: Dropdown de Categoria
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Categoria para Comparação',
              border: OutlineInputBorder(),
            ),
            value: _selectedCategory,
            items: _categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (newValue) =>
                setState(() => _selectedCategory = newValue),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Mês Atual',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedMonth1,
                  items: availableMonths
                      .map(
                        (month) =>
                            DropdownMenuItem(value: month, child: Text(month)),
                      )
                      .toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedMonth1 = newValue),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Mês de Comparação',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedMonth2,
                  items: availableMonths
                      .map(
                        (month) =>
                            DropdownMenuItem(value: month, child: Text(month)),
                      )
                      .toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedMonth2 = newValue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isComparisonEnabled
                ? () {
                    // Limpa o estado da comparação antes de rodar
                    setState(() => _comparisonData = {});
                    _runComparison(allLists);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.blue500,
              foregroundColor: AppColors.white,
            ),
            child: const Text(
              'Comparar Preços',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para exibir os resultados da comparação (Tabelas e Gráfico de Barras)
  Widget _buildComparisonResults(
    Map<String, List<ItemEntity>> data,
    String month1,
    String month2,
  ) {
    final List<ItemEntity> items1 = data[month1] ?? [];
    final List<ItemEntity> items2 = data[month2] ?? [];

    // 1. Coletar todos os nomes únicos de itens para a comparação
    final Set<String> allItemNames = {
      ...items1.map((i) => i.name.toLowerCase()),
      ...items2.map((i) => i.name.toLowerCase()),
    };

    final Map<String, double> prices1 = {
      for (var i in items1) i.name.toLowerCase(): i.price,
    };
    final Map<String, double> prices2 = {
      for (var i in items2) i.name.toLowerCase(): i.price,
    };

    final comparisonItems = allItemNames.map((name) {
      ItemEntity? findItem(List<ItemEntity> list, String lowerName) {
        try {
          return list.firstWhere((i) => i.name.toLowerCase() == lowerName);
        } catch (_) {
          return null;
        }
      }

      final item1 = findItem(items1, name);
      final item2 = findItem(items2, name);
      final originalName = item1?.name ?? item2?.name ?? name;

      return <String, dynamic>{
        'name': originalName,
        month1: prices1[name] ?? 0.0,
        month2: prices2[name] ?? 0.0,
      };
    }).toList();

    // Filtra itens onde pelo menos um dos preços é > 0
    final relevantItems = comparisonItems
        .where(
          (item) =>
              (item[month1] as double) > 0.0 || (item[month2] as double) > 0.0,
        )
        .toList();

    if (relevantItems.isEmpty) {
      return Center(
        child: Text(
          'Nenhum item da categoria "$_selectedCategory" com preço disponível para comparação nos meses selecionados.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildCardTitle('Detalhes da Lista de $month1'),
        _buildPriceTable(items1),

        const SizedBox(height: 16),
        _buildCardTitle('Detalhes da Lista de $month2'),
        _buildPriceTable(items2),

        const SizedBox(height: 24),
        _buildCardTitle('Comparação Visual (Preço por Item)'),
        _buildBarChartComparison(relevantItems, month1, month2),

        // BOTÃO DE EXPORTAÇÃO
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () =>
              _exportComparisonToPdf(relevantItems, month1, month2),
          icon: const Icon(Icons.picture_as_pdf, color: AppColors.white),
          label: const Text(
            'Exportar Comparativo para PDF',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // Tabela de Preços Simples para uma Lista (MANTIDO)
  Widget _buildPriceTable(List<ItemEntity> items) {
    if (items.isEmpty) return const Text('Nenhum item nesta lista.');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2.5),
            1: FlexColumnWidth(1.0),
            2: FlexColumnWidth(1.5),
          },
          children: [
            // Cabeçalho
            const TableRow(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(
                    'Item',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(
                    'Qtd',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(
                    'Preço Un.',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Linhas de Dados
            ...items.map((item) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(item.name),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(item.quantity.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'R\$ ${item.price.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Gráfico de Barras para Comparação de Preços Item a Item (MANTIDO)
  Widget _buildBarChartComparison(
    List<Map<String, dynamic>> comparisonItems,
    String month1,
    String month2,
  ) {
    final allPrices = comparisonItems
        .expand((item) => [item[month1] as double, item[month2] as double])
        .toList();
    final maxPrice = allPrices.isEmpty ? 1.0 : allPrices.reduce(max);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: comparisonItems.map((item) {
            final price1 = item[month1] as double;
            final price2 = item[month2] as double;
            final name = item['name'] as String;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  // Barra Mês 1
                  _buildBar(
                    month1,
                    price1,
                    maxPrice,
                    AppColors.primary,
                    price2,
                  ),
                  // Barra Mês 2
                  _buildBar(
                    month2,
                    price2,
                    maxPrice,
                    AppColors.blue500,
                    price1,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Função auxiliar _buildBar com a correção de lógica de comparação (MANTIDO)
  Widget _buildBar(
    String label,
    double value,
    double max,
    Color color,
    double comparisonValue,
  ) {
    final barWidthFactor = max > 0 ? (value / max) * 0.9 : 0.0;

    Color labelColor = Colors.black87;
    if (comparisonValue > 0) {
      if (value < comparisonValue) {
        labelColor = Colors.green.shade600;
      } else if (value > comparisonValue) {
        labelColor = Colors.red.shade600;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label.substring(0, 5),
              style: TextStyle(fontSize: 10, color: color),
            ),
          ),
          Expanded(
            child: Container(
              height: 18,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: barWidthFactor,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter para desenhar a fatia do gráfico de pizza (simplificado) (MANTIDO)
class _PieSlicePainter extends CustomPainter {
  final Color color;
  final double startAngle;
  final double sweepAngle;

  _PieSlicePainter({
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2);

    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
