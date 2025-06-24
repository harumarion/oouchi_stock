/// セール情報を表すエンティティ
class PriceInfo {
  /// ドキュメントID
  final String id;

  /// ひも付く在庫ID
  final String inventoryId;

  /// 調査日
  final DateTime checkedAt;

  /// カテゴリ名
  final String category;

  /// 品種名
  final String itemType;

  /// 商品名
  final String itemName;

  /// 購入数
  final double count;

  /// 単位
  final String unit;

  /// 1個あたり容量
  final double volume;

  /// 総容量
  final double totalVolume;

  /// 通常価格
  final double regularPrice;

  /// セール価格
  final double salePrice;

  /// 購入店舗
  final String shop;

  /// 承認ページURL
  final String approvalUrl;

  /// メモ
  final String memo;

  /// 単価
  final double unitPrice;

  /// セール期限
  final DateTime expiry;

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
    required this.expiry,
  });

  /// セール期限が [date] より前かどうか判定
  bool isExpired(DateTime date) => expiry.isBefore(date);
}
