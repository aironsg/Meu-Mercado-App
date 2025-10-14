// lib/features/lists/presentation/pages/lists_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meu_mercado/core/theme/app_colors.dart';
import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';
import 'package:meu_mercado/features/lists/presentation/controller/list_controller.dart';
import 'package:meu_mercado/features/lists/presentation/pages/item_card.dart';
import 'package:meu_mercado/features/lists/presentation/provider/lists_provider.dart';
import 'package:uuid/uuid.dart'; // 🚨 NOVO: Para criar IDs para novos itens

class ListPage extends ConsumerStatefulWidget {
  const ListPage({super.key});

  @override
  ConsumerState<ListPage> createState() => _ListPageState();
}

class _ListPageState extends ConsumerState<ListPage> {
  ItemEntity? _editingItem;
  String? _editingListId;
  bool _isUpdating = false;

  // 🚨 NOVO: Flag para saber se estamos ADICIONANDO um novo item
  bool _isAddingNewItem = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(listControllerProvider.notifier).loadLists();
    });
  }

  // 🚨 NOVO: Função para confirmar e deletar a lista
  Future<void> _confirmAndDeleteList(
    ListController controller,
    String listId,
    String dateString,
  ) async {
    final bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Excluir Lista'),
            content: Text(
              'Tem certeza que deseja excluir a lista de compras de $dateString? Esta ação é irreversível.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      setState(() => _isUpdating = true);
      final success = await controller.deleteShoppingList(listId);
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Lista excluída com sucesso!'
                  : 'Erro ao excluir a lista!',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  // 🚨 NOVO: Função para confirmar e remover um item
  Future<void> _confirmAndRemoveItem(
    ListController controller,
    String listId,
    ItemEntity item,
  ) async {
    final bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remover Item'),
            content: Text(
              'Tem certeza que deseja remover o item "${item.name}" desta lista?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Remover',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      setState(() => _isUpdating = true);
      final success = await controller.removeItemFromHistoryList(
        listId: listId,
        itemId: item.id,
      );
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Item removido com sucesso!'
                  : 'Erro ao remover o item!',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  // 🚨 NOVO: Função que será passada para o ItemCard para salvar (adicionar/editar)
  Future<void> _saveItemCallback(
    ListController controller,
    String listId,
    ItemEntity itemToSave,
  ) async {
    setState(() => _isUpdating = true);
    final isNew = _isAddingNewItem;

    // A chamada do controller agora lida com ADD ou UPDATE
    final success = await controller.saveItemInHistoryList(
      listId: listId,
      itemToSave: itemToSave,
    );

    if (mounted) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Item ${isNew ? 'adicionado' : 'atualizado'} com sucesso!'
                : 'Erro ao salvar o item!',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      // Fecha o card e reseta o estado de edição
      setState(() {
        _editingItem = null;
        _editingListId = null;
        _isAddingNewItem = false;
      });
    }
  }

  // 🚨 NOVO: Define um novo item (template) para o modal de adição
  void _startAddItem(String listId) {
    setState(() {
      _editingListId = listId;
      _isAddingNewItem = true;
      // Cria uma entidade ItemEntity vazia, mas com um ID novo
      _editingItem = ItemEntity.create(
        name: '',
        category: 'GERAIS', // Valor padrão
        quantity: 1,
        price: 0.0,
        note: '',
      );
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
          onPressed: () => Modular.to.navigate("/home"),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: controller.loadLists,
            child: state.loading && state.lists.isEmpty
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

          // Overlay do ItemCard (Modal para Adição/Edição)
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
                        isNewItem: _isAddingNewItem, // 🚨 NOVO
                        onSave: (updatedItem) => _saveItemCallback(
                          controller,
                          _editingListId!,
                          updatedItem,
                        ),
                        onCancel: () {
                          // 🚨 NOVO: Reseta o estado ao cancelar
                          setState(() {
                            _editingItem = null;
                            _editingListId = null;
                            _isAddingNewItem = false;
                          });
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
        leading: Row(
          // 🚨 NOVO: Botões de Ação na Lista (Adicionar e Deletar Lista)
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.success,
              ),
              onPressed: () =>
                  _startAddItem(listId), // Inicia o fluxo de adição
              tooltip: 'Adicionar Item',
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: AppColors.danger),
              onPressed: () =>
                  _confirmAndDeleteList(controller, listId, dateString),
              tooltip: 'Excluir Lista',
            ),
          ],
        ),
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
                    // Inicia o fluxo de edição
                    setState(() {
                      _editingItem = item;
                      _editingListId = listId;
                      _isAddingNewItem = false;
                    });
                  },
                ),
                // 🚨 NOVO: Botão de exclusão de item
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 20,
                    color: AppColors.danger,
                  ),
                  onPressed: () =>
                      _confirmAndRemoveItem(controller, listId, item),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
