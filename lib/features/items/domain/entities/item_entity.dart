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
    required this.quantity,
    required this.price,
    this.note,
  });
}
