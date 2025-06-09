class InventoryItem {
  final String itemName;
  final String category;
  final int quantity;
  final String unit;
  final String note;

  InventoryItem({
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    this.note = '',
  });
}
