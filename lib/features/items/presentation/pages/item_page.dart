import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/item_entity.dart';
import '../controller/item_controller.dart';
import '../state/item_state.dart';
import '../../../../core/theme/app_colors.dart'; // Assumindo este caminho

class ItemPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? itemToEdit; // Argumento de navegação opcional

  const ItemPage({super.key, this.itemToEdit});

  @override
  ConsumerState<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends ConsumerState<ItemPage> {
  // Chave global para o formulário
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos de texto
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  // Guarda o ID do item sendo editado (se houver)
  String? _editingItemId;

  @override
  void initState() {
    super.initState();

    // 🚨 LÓGICA DE EDIÇÃO VIA ARGUMENTO MODULAR
    // Verifica se a página recebeu um Map (ItemEntity.toMap()) do fluxo de ListPage
    final itemArgs = Modular.args.data;

    if (itemArgs is Map<String, dynamic> && itemArgs.containsKey('id')) {
      final itemToEdit = ItemEntity.fromMap(itemArgs);

      // Carrega o item no formulário após o frame ser desenhado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadItemForEdit(itemToEdit);
      });
    }
  }

  void _loadItemForEdit(ItemEntity item) {
    setState(() {
      _editingItemId = item.id;
      _nameController.text = item.name;
      _categoryController.text = item.category;
      _priceController.text = item.price.toString();
      _quantityController.text = item.quantity.toString();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Lógica principal: Adicionar ou Atualizar item na lista temporária
  void _submitItem(ItemController controller) {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final category = _categoryController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final quantity = int.tryParse(_quantityController.text) ?? 1;

    final newItem = ItemEntity(
      // Se _editingItemId for null, o ID será um UUID novo gerado no construtor
      id: _editingItemId ?? UniqueKey().toString(),
      name: name,
      category: category,
      price: price,
      quantity: quantity,
      // Você pode adicionar um campo isDone=false se necessário
    );

    if (_editingItemId != null) {
      // 1. Atualiza na lista temporária de edição
      controller.updateItemInEditingList(newItem);

      // 2. Limpa o modo de edição e navega de volta (se vier de ListPage)
      _resetForm();
      Modular.to.pop();
    } else {
      // 1. Adiciona à lista temporária
      controller.addItemToEditingList(newItem);

      // 2. Reseta o formulário
      _resetForm();
    }
  }

  void _resetForm() {
    setState(() {
      _editingItemId = null;
    });
    _formKey.currentState?.reset();
    _nameController.clear();
    _categoryController.clear();
    _priceController.clear();
    _quantityController.clear();
  }

  void _removeItemFromList(ItemController controller, String itemId) {
    controller.removeItemFromEditingList(itemId);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(itemControllerProvider.notifier);
    final state = ref.watch(itemControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editingItemId != null ? 'Editar Item' : 'Cadastro de Item',
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            onPressed: state.editingItems.isNotEmpty && _editingItemId == null
                ? controller.registerList
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.resetList,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FORMULÁRIO
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Item',
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Preço Estimado',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state.loading
                          ? null
                          : () => _submitItem(controller),
                      icon: Icon(
                        _editingItemId != null ? Icons.save : Icons.add,
                      ),
                      label: Text(
                        _editingItemId != null
                            ? 'Salvar Edição'
                            : 'Adicionar à Lista',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _editingItemId != null
                            ? Colors.blue
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // LISTA TEMPORÁRIA DE ITENS
            Text(
              'Lista Temporária (${state.editingItems.length} itens)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            state.editingItems.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('Nenhum item adicionado ainda.'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.editingItems.length,
                    itemBuilder: (context, index) {
                      final item = state.editingItems[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.quantity} x R\$ ${item.price.toStringAsFixed(2)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _removeItemFromList(controller, item.id),
                        ),
                        // Permite editar diretamente na lista temporária
                        onTap: () => _loadItemForEdit(item),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
