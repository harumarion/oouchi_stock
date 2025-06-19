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
  // 通常価格
  final double regularPrice;
  // セール価格
  final double salePrice;
  final String shop;
  // 承認ページURL
  final String approvalUrl;
  // メモ
  final String memo;
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
    required this.regularPrice,
    required this.salePrice,
    required this.shop,
    required this.approvalUrl,
    required this.memo,
    required this.unitPrice,
  });
}
