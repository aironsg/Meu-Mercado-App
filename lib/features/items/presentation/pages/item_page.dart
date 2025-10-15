import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_mercado/core/theme/app_colors.dart';
import 'package:meu_mercado/core/widgets/app_background.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/item_entity.dart';
import '../controller/item_controller.dart';

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

class ItemPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? itemToEdit;

  const ItemPage({super.key, this.itemToEdit});

  @override
  ConsumerState<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends ConsumerState<ItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  String? _editingItemId;

  final List<String> _categories = [
    'MERCADO',
    'FEIRA',
    'ROUPAS',
    'CASA',
    'GERAIS',
  ];
  String? _selectedCategory;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  final _currencyInputFormatter = CurrencyInputFormatter();

  double _getRawPrice(String maskedValue) {
    if (maskedValue.isEmpty) return 0.0;
    String clean = maskedValue
        .replaceAll(RegExp(r'[^\d,]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(clean) ?? 0.0;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _loadItemForEdit(ItemEntity item) {
    String priceFormatted = item.price > 0.0
        ? _currencyInputFormatter
              .formatEditUpdate(
                TextEditingValue.empty,
                TextEditingValue(text: (item.price * 100).toInt().toString()),
              )
              .text
        : '';

    _nameController.text = item.name;
    _quantityController.text = item.quantity.toString();
    _priceController.text = priceFormatted;
    _noteController.text = item.note ?? '';

    setState(() {
      _selectedCategory = item.category;
      _editingItemId = item.id;
    });
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
      _editingItemId = null;
    });
  }

  void _submitItem(ItemController controller) {
    if (!_formKey.currentState!.validate()) return;

    final double rawPrice = _getRawPrice(_priceController.text);

    final newItem = ItemEntity(
      id: _editingItemId ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      category: _selectedCategory ?? 'GERAIS',
      quantity: int.tryParse(_quantityController.text) ?? 0,
      price: rawPrice,
      note: _noteController.text.trim(),
    );

    if (_editingItemId != null) {
      controller.updateItemInEditingList(newItem);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item atualizado com sucesso!')),
      );
    } else {
      controller.addItemToEditingList(newItem);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item adicionado à lista!')));
    }

    _resetEditingState();
  }

  @override
  void initState() {
    super.initState();
    final itemArgs = widget.itemToEdit;
    if (itemArgs != null && itemArgs.containsKey('id')) {
      final itemToEdit = ItemEntity.fromMap(itemArgs);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadItemForEdit(itemToEdit);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemControllerProvider);
    final controller = ref.read(itemControllerProvider.notifier);

    final isRegisterListButtonActive =
        !state.loading && state.editingItems.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editingItemId != null ? 'Editar Item' : 'Cadastro de Itens',
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Modular.to.navigate("/home"),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // 🔹 Espaço extra entre a AppBar e os campos
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: _inputDecoration('Categoria'),
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
                                    _currencyInputFormatter,
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _noteController,
                            decoration: _inputDecoration('Observações'),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: Icon(
                              _editingItemId != null
                                  ? Icons.save
                                  : Icons.add_circle_outline,
                              size: 24,
                            ),
                            label: Text(
                              _editingItemId != null
                                  ? 'Salvar Alterações'
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
                              backgroundColor: _editingItemId != null
                                  ? Colors.orange.shade700
                                  : Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: state.loading
                                ? null
                                : () => _submitItem(controller),
                          ),
                          if (_editingItemId != null)
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
                      'Itens na Lista',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    if (state.editingItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Center(
                          child: Text('Nenhum item adicionado ainda.'),
                        ),
                      ),
                    ...state.editingItems.map((item) {
                      final priceDisplay = item.price > 0.0
                          ? _currencyFormatter.format(item.price)
                          : 'Sem preço';
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            '${item.name} (${item.category})',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${item.quantity}x | R\$ $priceDisplay',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _loadItemForEdit(item),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => controller
                                    .removeItemFromEditingList(item.id),
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
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: isRegisterListButtonActive
                ? Colors.green.shade600
                : Colors.grey,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: isRegisterListButtonActive
              ? () async {
                  await controller.registerList();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lista cadastrada com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _resetEditingState();
                    setState(() {
                      _selectedCategory = null;
                    });
                  }
                }
              : null,
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
