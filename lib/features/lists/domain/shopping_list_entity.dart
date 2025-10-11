import 'package:equatable/equatable.dart';
import '../../items/domain/entities/item_entity.dart';

class ShoppingListEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final DateTime createdAt;
  final List<ItemEntity> items;

  const ShoppingListEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.items,
  });

  @override
  List<Object?> get props => [id, name, category, createdAt, items];
}
