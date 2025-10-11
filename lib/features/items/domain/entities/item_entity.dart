import 'package:uuid/uuid.dart';

class ItemEntity {
  final String id; // Chave única, essencial para edição e remoção
  final String name;
  final String category;
  final int quantity;
  final double price; // Pode ser 0.0, indicando "A preencher"
  final String? note;

  ItemEntity({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.price = 0.0,
    this.note,
  });

  // Converte a Entidade em um Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'price': price,
      'note': note,
    };
  }

  // Cria a Entidade a partir de um Map (lendo do Firestore)
  factory ItemEntity.fromMap(Map<String, dynamic> map) {
    return ItemEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      note: map['note'] as String?,
    );
  }
}
