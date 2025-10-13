import 'package:flutter/material.dart';
import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';

class ItemCard extends StatefulWidget {
  final ItemEntity item;
  final Future<void> Function(ItemEntity updatedItem) onSave;

  const ItemCard({Key? key, required this.item, required this.onSave})
    : super(key: key);

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _isExpanded = false;

  // Controllers para os campos de texto
  late TextEditingController categoryController;
  late TextEditingController nameController;
  late TextEditingController noteController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
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
    _selectedCategory = widget.item.category;
    nameController = TextEditingController(text: widget.item.name);
    noteController = TextEditingController(text: widget.item.note);
    priceController = TextEditingController(text: widget.item.price.toString());
    quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
  }

  @override
  void dispose() {
    categoryController.dispose();
    nameController.dispose();
    noteController.dispose();
    priceController.dispose();
    quantityController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,

              children: [
                Text(
                  "Item: ${widget.item.name}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
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
          TextField(
            controller: noteController,
            decoration: _inputDecoration('Descrição'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Preço'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Quantidade'),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Salvar alterações',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                final updated = widget.item.copyWith(
                  name: nameController.text,
                  note: noteController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  quantity: int.tryParse(quantityController.text) ?? 0,
                );

                await widget.onSave(updated);
                setState(() => _isExpanded = false); // Fecha o card
              },
            ),
          ),
        ],
      ),
    );
  }
}
