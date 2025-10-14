// lib/features/lists/presentation/pages/item_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';
import 'package:meu_mercado/features/items/presentation/pages/item_page.dart'; // Para CurrencyInputFormatter e lógica de preço

class ItemCard extends StatefulWidget {
  final ItemEntity item;
  final bool isNewItem; // 🚨 NOVO: Flag para saber se é um novo item
  final Future<void> Function(ItemEntity updatedItem) onSave;
  final VoidCallback onCancel; // 🚨 NOVO: Callback para cancelar

  const ItemCard({
    Key? key,
    required this.item,
    required this.onSave,
    required this.onCancel,
    this.isNewItem = false,
  }) : super(key: key);

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  // Controllers para os campos de texto
  late TextEditingController nameController;
  late TextEditingController noteController;
  late TextEditingController priceController;
  late TextEditingController quantityController;

  // 🚨 NOVO: Instância do Formatador de Moeda
  final CurrencyInputFormatter _currencyInputFormatter =
      CurrencyInputFormatter();

  final List<String> _categories = [
    'MERCADO',
    'FEIRA',
    'ROUPAS',
    'CASA',
    'GERAIS',
  ];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Inicializa o preço no formato R$ 0,00 se for edição
    String formattedPrice = widget.item.price > 0.0
        ? _currencyInputFormatter
              .formatEditUpdate(
                TextEditingValue.empty,
                // Converte o preço (ex: 12.50) para centavos (1250) para formatar
                TextEditingValue(
                  text: (widget.item.price * 100).toInt().toString(),
                ),
              )
              .text
        : '';

    _selectedCategory = widget.item.category;
    nameController = TextEditingController(text: widget.item.name);
    noteController = TextEditingController(text: widget.item.note);
    priceController = TextEditingController(text: formattedPrice);
    quantityController = TextEditingController(
      text: widget.item.quantity == 0 || widget.item.quantity == 1
          ? ''
          : widget.item.quantity.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant ItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recarrega os dados se o item mudar (útil para o fluxo de adição)
    if (oldWidget.item.id != widget.item.id) {
      _disposeControllers();
      _initializeControllers();
    }
  }

  void _disposeControllers() {
    nameController.dispose();
    noteController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
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

  // 🚨 NOVO: Replicando a função de `ItemPage` para obter o preço real
  double _getRawPrice(String maskedValue) {
    if (maskedValue.isEmpty) return 0.0;
    String clean = maskedValue
        .replaceAll(RegExp(r'[^\d]'), '') // Remove tudo que não é dígito
        .replaceAll('.', '')
        .replaceAll(',', '.');

    // Converte de centavos (implícito pelo formatter) para o valor double
    return (double.tryParse(clean) ?? 0.0) / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isNewItem ? 'Adicionar Novo Item' : 'Editar Item',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Campo de Categoria
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
              const SizedBox(height: 10),

              // Campo de Nome
              TextField(
                controller: nameController,
                decoration: _inputDecoration('Nome do Item'),
              ),
              const SizedBox(height: 10),

              // Campo de Observação
              TextField(
                controller: noteController,
                decoration: _inputDecoration('Observações'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Quantidade'),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Preço'),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _currencyInputFormatter,
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botões de Ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel, // 🚨 NOVO: Botão de Cancelar
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isNewItem
                          ? Colors.green[600]
                          : Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      widget.isNewItem ? Icons.add : Icons.save,
                      color: Colors.white,
                    ),
                    label: Text(
                      widget.isNewItem ? 'Adicionar' : 'Salvar alterações',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      final rawPrice = _getRawPrice(priceController.text);
                      final quantity =
                          int.tryParse(quantityController.text) ?? 1;

                      final itemToSave = widget.item.copyWith(
                        id: widget.item.id,
                        name: nameController.text.trim(),
                        category: _selectedCategory ?? 'GERAIS',
                        quantity: quantity < 1
                            ? 1
                            : quantity, // Garante que a quantidade mínima é 1
                        price: rawPrice,
                        note: noteController.text.trim(),
                      );

                      await widget.onSave(itemToSave);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
