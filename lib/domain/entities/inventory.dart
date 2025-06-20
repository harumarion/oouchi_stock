/// 在庫情報を表すエンティティ
class Inventory {
  /// Firestore ドキュメントID
  final String id;

  /// 商品名
  final String itemName;

  /// カテゴリ名
  final String category;

  /// 品種名
  final String itemType;

  /// 数量
  final double quantity;

  /// 単位
  final String unit;

  /// 任意のメモ
  final String note;

  /// 作成日時
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
