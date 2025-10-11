class ItemEntity {
  final int? id;
  final String name;
  final int quantity;
  final double estimatedPrice;
  final bool purchased;
  final DateTime createdAt;

  ItemEntity({
    this.id,
    required this.name,
    required this.quantity,
    required this.estimatedPrice,
    required this.purchased,
    required this.createdAt,
  });
}
