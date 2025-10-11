import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  // 1. NOVA IMPLEMENTAÇÃO DA MÁSCARA: Usando MaskTextInputFormatter
  // Configura um limite de 10 dígitos antes da vírgula e 2 depois.
  final _currencyMaskFormatter = MaskTextInputFormatter(
    mask: 'R\$ #.###.###,##0,00',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // FUNÇÃO AUXILIAR PARA EXTRAIR O VALOR LIMPO DA MÁSCARA
  double _getRawPrice(String maskedValue) {
    if (maskedValue.isEmpty) return 0.0;

    // 1. Remove o símbolo "R$" e espaços
    String cleanText = maskedValue.replaceAll('R\$', '').trim();
    // 2. Remove o separador de milhar (ponto)
    cleanText = cleanText.replaceAll('.', '');
    // 3. Troca o separador decimal (vírgula) por ponto (padrão double do Dart)
    cleanText = cleanText.replaceAll(',', '.');

    // 4. Converte para double. Se falhar, retorna 0.0
    return double.tryParse(cleanText) ?? 0.0;
  }

  // Estilo reutilizável para campos de entrada
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

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Itens'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Nome do Item'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: _inputDecoration('Categoria'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: _inputDecoration('Quantidade'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              // Campo de Preço com Máscara
              TextFormField(
                controller: _priceController,
                decoration: _inputDecoration('Preço'),
                keyboardType: TextInputType.number,
                // Aplica a nova máscara
                inputFormatters: [_currencyMaskFormatter],
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  // Validação usando a função auxiliar
                  final rawPrice = _getRawPrice(v);
                  if (rawPrice <= 0) {
                    return 'O preço deve ser maior que zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: _inputDecoration('Observação'),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: state.loading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          // 2. EXTRAÇÃO DE VALOR USANDO A FUNÇÃO AUXILIAR
                          final double rawPrice = _getRawPrice(
                            _priceController.text,
                          );

                          final newItem = ItemEntity(
                            id: const Uuid().v4(),
                            name: _nameController.text.trim(),
                            category: _categoryController.text.trim(),
                            quantity:
                                int.tryParse(_quantityController.text) ?? 0,
                            price: rawPrice,
                            note: _noteController.text.trim(),
                          );

                          await ref
                              .read(itemControllerProvider.notifier)
                              .addItem(newItem);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Item cadastrado com sucesso!'),
                              ),
                            );

                            // Limpa os campos após cadastro
                            _nameController.clear();
                            _categoryController.clear();
                            _quantityController.clear();
                            _priceController.clear();
                            _noteController.clear();
                          }
                        }
                      },
                child: state.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Cadastrar', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
