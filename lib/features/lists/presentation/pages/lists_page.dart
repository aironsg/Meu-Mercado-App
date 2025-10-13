import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meu_mercado/core/theme/app_colors.dart';
import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';
import 'package:meu_mercado/features/lists/presentation/controller/list_controller.dart';
import 'package:meu_mercado/features/lists/presentation/pages/item_card.dart';
import 'package:meu_mercado/features/lists/presentation/provider/lists_provider.dart';

class ListPage extends ConsumerStatefulWidget {
  const ListPage({super.key});

  @override
  ConsumerState<ListPage> createState() => _ListPageState();
}

class _ListPageState extends ConsumerState<ListPage> {
  ItemEntity? _editingItem;
  String? _editingListId;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(listControllerProvider.notifier).loadLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listControllerProvider);
    final controller = ref.read(listControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Compras'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Modular.to.pushNamed("/home"),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: controller.loadLists,
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(child: Text('Erro: ${state.error}'))
                : state.lists.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma lista encontrada.\nCrie sua primeira lista!',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.lists.length,
                    itemBuilder: (context, index) {
                      final listData = state.lists[index];
                      return _buildListCard(context, controller, listData);
                    },
                  ),
          ),

          // Overlay do ItemCard
          if (_editingItem != null && _editingListId != null)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ItemCard(
                        item: _editingItem!,
                        onSave: (updatedItem) async {
                          setState(() => _isUpdating = true);
                          final success = await ref
                              .read(listControllerProvider.notifier)
                              .updateItemInHistoryList(
                                listId: _editingListId!,
                                updatedItem: updatedItem,
                              );

                          if (mounted) {
                            setState(() => _isUpdating = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Item atualizado com sucesso!'
                                      : 'Erro ao atualizar o item!',
                                ),
                                backgroundColor: success
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );

                            // Fecha o card e recarrega listas
                            setState(() {
                              _editingItem = null;
                              _editingListId = null;
                            });
                            await ref
                                .read(listControllerProvider.notifier)
                                .loadLists();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (_isUpdating)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(),
                      SizedBox(height: 12),
                      Text(
                        'Salvando alterações...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListCard(
    BuildContext context,
    ListController controller,
    Map<String, dynamic> listData,
  ) {
    final DateTime? date = listData['createdAt'] as DateTime?;
    final List<ItemEntity> items = listData['items'] as List<ItemEntity>? ?? [];

    final String listId = listData['id'] ?? '';
    final String dateString = date != null
        ? DateFormat('dd/MM/yyyy - HH:mm').format(date)
        : 'Data Desconhecida';

    final double totalEstimate = items.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.shopping_basket, color: Colors.green),
        title: Text(
          'Lista de Compras: $dateString',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${items.length} itens | Total Estimado: R\$ ${totalEstimate.toStringAsFixed(2)}',
        ),
        children: items.map((item) {
          final priceDisplay = item.price > 0.0
              ? 'R\$ ${item.price.toStringAsFixed(2)}'
              : 'A preencher';

          return ListTile(
            contentPadding: const EdgeInsets.only(left: 32, right: 16),
            dense: true,
            title: Text(item.name),
            subtitle: Text('${item.category} | ${item.quantity} un.'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(priceDisplay),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      _editingItem = item;
                      _editingListId = listId;
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
