import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart'; // Adicionar import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';
import 'package:meu_mercado/features/lists/presentation/provider/lists_provider.dart';

import '../controller/list_controller.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listControllerProvider);
    final controller = ref.read(listControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Compras'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadLists, // Recarrega a lista
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
    );
  }

  Widget _buildListCard(
    BuildContext context,
    ListController controller,
    Map<String, dynamic> listData,
  ) {
    // Converte os dados do Repositório
    final DateTime? date = listData['createdAt'] as DateTime?;
    final List<ItemEntity> items = listData['items'] as List<ItemEntity>? ?? [];

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

        // CORPO DA TABELA EXPANDIDA (ITENS)
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
                // BOTÃO EDITAR ITEM: Navega para ItemPage
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                  onPressed: () {
                    // 🚨 CORREÇÃO: Usa Modular.to.navigate e passa o Map do item
                    Modular.to.navigate('/item', arguments: item.toMap());
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
