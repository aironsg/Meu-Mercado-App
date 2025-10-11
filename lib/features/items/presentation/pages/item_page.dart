import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/item_entity.dart';
import '../item_controller.dart';

class ItemPage extends ConsumerStatefulWidget {
  const ItemPage({super.key});

  @override
  ConsumerState<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends ConsumerState<ItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  ItemEntity? _itemBeingEdited;

  final List<String> _categories = [
    'MERCADO',
    'FEIRA',
    'ROUPAS',
    'CASA',
    'GERAIS',
  ];
  String? _selectedCategory;

  // ✅ Formatador de moeda padrão
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  // ✅ Função para obter o valor numérico (double)
  double _getRawPrice(String maskedValue) {
    if (maskedValue.isEmpty) return 0.0;
    String clean = maskedValue
        .replaceAll(RegExp(r'[^0-9,]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(clean) ?? 0.0;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _editItem(ItemEntity item) {
    String priceFormatted = item.price > 0.0
        ? _currencyFormatter.format(item.price)
        : '';

    _nameController.text = item.name;
    _quantityController.text = item.quantity.toString();
    _priceController.text = priceFormatted;
    _noteController.text = item.note ?? '';

    setState(() {
      _selectedCategory = item.category;
      _itemBeingEdited = item;
    });

    Scrollable.ensureVisible(
      context,
      alignment: 0.0,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _clearItemFields() {
    _nameController.clear();
    _quantityController.clear();
    _priceController.clear();
    _noteController.clear();
  }

  void _resetEditingState() {
    _clearItemFields();
    setState(() {
      _itemBeingEdited = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<String?> _showCategoryDialog(BuildContext context) async {
    String? tempSelectedCategory = _categories.first;

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione a Categoria Anterior'),
          content: DropdownButtonFormField<String>(
            value: tempSelectedCategory,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              tempSelectedCategory = newValue;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(tempSelectedCategory),
              child: const Text('Buscar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemControllerProvider);
    final controller = ref.read(itemControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _itemBeingEdited != null ? 'Editando Item' : 'Cadastro de Itens',
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.resetList();
                        _resetEditingState();
                        setState(() {
                          _selectedCategory = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nova lista de compras iniciada!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Nova Lista'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final category = await _showCategoryDialog(context);
                        if (category != null) {
                          await controller.loadPreviousItems(category);
                          _resetEditingState();
                          setState(() {
                            _selectedCategory = category;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Itens de $category carregados da lista anterior.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('Lista Anterior'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: _inputDecoration(
                            'Categoria (Obrigatório)',
                          ),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                          validator: (v) =>
                              v == null ? 'Selecione uma categoria' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration('Nome do Item'),
                          validator: (v) =>
                              v!.isEmpty ? 'Campo obrigatório' : null,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _quantityController,
                                decoration: _inputDecoration('Quantidade'),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                decoration: _inputDecoration(
                                  'Preço (Opcional)',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  CurrencyInputFormatter(), // ✅ Novo formatador correto
                                ],
                                validator: (v) {
                                  if (v != null && v.isNotEmpty) {
                                    final rawPrice = _getRawPrice(v);
                                    if (rawPrice <= 0) {
                                      return 'Preço não pode ser zero';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _noteController,
                          decoration: _inputDecoration('Observação'),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: Icon(
                            _itemBeingEdited != null
                                ? Icons.save
                                : Icons.add_circle_outline,
                            size: 24,
                          ),
                          label: Text(
                            _itemBeingEdited != null
                                ? 'Salvar Edição'
                                : 'Adicionar Item à Lista',
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: _itemBeingEdited != null
                                ? Colors.orange.shade700
                                : Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: state.loading || _selectedCategory == null
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final double rawPrice = _getRawPrice(
                                      _priceController.text,
                                    );

                                    final newItem = ItemEntity(
                                      id:
                                          _itemBeingEdited?.id ??
                                          const Uuid().v4(),
                                      name: _nameController.text.trim(),
                                      category: _selectedCategory!,
                                      quantity:
                                          int.tryParse(
                                            _quantityController.text,
                                          ) ??
                                          0,
                                      price: rawPrice,
                                      note: _noteController.text.trim(),
                                    );

                                    if (_itemBeingEdited != null) {
                                      controller.updateItemInEditingList(
                                        newItem,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Item atualizado com sucesso!',
                                          ),
                                        ),
                                      );
                                    } else {
                                      controller.addItemToEditingList(newItem);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Item adicionado à lista temporária!',
                                          ),
                                        ),
                                      );
                                    }
                                    _resetEditingState();
                                  }
                                },
                        ),
                        if (_itemBeingEdited != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextButton(
                              onPressed: _resetEditingState,
                              child: const Text(
                                'Cancelar Edição',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                  const Text(
                    'Itens na Lista (Edição)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  if (state.editingItems.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          'Nenhum item adicionado ainda. Comece a adicionar!',
                        ),
                      ),
                    ),
                  ...state.editingItems.map((item) {
                    final priceDisplay = item.price > 0.0
                        ? 'R\$ ${item.price.toStringAsFixed(2)}'
                        : 'A preencher';
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: _itemBeingEdited?.id == item.id
                          ? Colors.yellow.shade100
                          : Colors.white,
                      child: ListTile(
                        title: Text(
                          '${item.name} (${item.category})',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('${item.quantity} un. | $priceDisplay'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editItem(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  controller.removeItemFromEditingList(item.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: state.editingItems.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 5,
                ),
                onPressed: state.loading
                    ? null
                    : () async {
                        await controller.registerList();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lista Cadastrada com Sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _resetEditingState();
                          setState(() {
                            _selectedCategory = null;
                          });
                        }
                      },
                child: state.loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Cadastrar Lista Completa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )
          : null,
    );
  }
}

// ✅ Formatador customizado: digitação da direita para a esquerda (centavos → milhões)
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$ ',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) newText = '0';

    double value = double.parse(newText) / 100.0;
    final newString = _formatter.format(value);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
