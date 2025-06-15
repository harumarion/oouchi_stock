class Inventory {
  final String id;
  final String itemName;
  final String category;
  final String itemType;
  final double quantity;
  final String unit;
  final String note;
  final DateTime createdAt;

  Inventory({
    required this.id,
    required this.itemName,
    required this.category,
    required this.itemType,
    required this.quantity,
    required this.unit,
    this.note = '',
    required this.createdAt,
  });
}
