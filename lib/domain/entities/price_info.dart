class PriceInfo {
  final String id;
  final String inventoryId;
  final DateTime checkedAt;
  final String category;
  final String itemType;
  final String itemName;
  final double count;
  final String unit;
  final double volume;
  final double totalVolume;
  final double price;
  final String shop;
  final double unitPrice;

  PriceInfo({
    required this.id,
    required this.inventoryId,
    required this.checkedAt,
    required this.category,
    required this.itemType,
    required this.itemName,
    required this.count,
    required this.unit,
    required this.volume,
    required this.totalVolume,
    required this.price,
    required this.shop,
    required this.unitPrice,
  });
}
