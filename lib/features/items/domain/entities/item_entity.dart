// lib/features/items/domain/entities/item_entity.dart
import 'package:uuid/uuid.dart';

class ItemEntity {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final double price;
  final String? note;

  ItemEntity({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.price = 0.0,
    this.note,
  });

  /// Gera um novo ID automaticamente (útil ao criar novos itens)
  factory ItemEntity.create({
    required String name,
    required String category,
    int quantity = 1,
    double price = 0.0,
    String? note,
  }) {
    return ItemEntity(
      id: const Uuid().v4(),
      name: name,
      category: category,
      quantity: quantity,
      price: price,
      note: note,
    );
  }

  ItemEntity copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    double? price,
    String? note,
  }) {
    return ItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      note: note ?? this.note,
    );
  }

  /// Converte a Entidade em Map (para salvar no Firestore)
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

  /// Cria a Entidade a partir de um Map (lendo do Firestore)
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

  @override
  String toString() {
    return 'ItemEntity(id: $id, name: $name, category: $category, quantity: $quantity, price: $price, note: $note)';
  }
}
