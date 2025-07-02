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

  /// 1個あたりの容量
  final double volume;

  /// 総容量
  final double totalVolume;

  /// 単位
  final String unit;

  /// 任意のメモ
  final String note;

  /// 月あたりの消費量
  final double monthlyConsumption;

  /// 作成日時
  final DateTime createdAt;

  Inventory({
    required this.id,
    required this.itemName,
    required this.category,
    required this.itemType,
    required this.quantity,
    this.volume = 0,
    this.totalVolume = 0,
    required this.unit,
    this.note = '',
    this.monthlyConsumption = 0,
    required this.createdAt,
  });

  // ID を利用して等価比較を行う
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Inventory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// 数量と容量から総容量を再計算
  double calculateTotalVolume() => quantity * volume;
}
