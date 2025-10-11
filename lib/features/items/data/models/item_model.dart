import '../../domain/entities/item_entity.dart';

class ItemModel extends ItemEntity {
  ItemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.quantity,
    required super.price,
    super.note,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      note: map['note'] as String?,
    );
  }

  factory ItemModel.fromFirestoreMap(Map<String, dynamic> map) {
    // Caso o dado venha do Firestore (garanta types)
    return ItemModel.fromMap(map);
  }

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
}
