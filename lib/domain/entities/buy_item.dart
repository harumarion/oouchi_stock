/// 買い物リストの1項目を表すエンティティ
/// [inventoryId] が存在する場合、在庫データとの関連を示す
class BuyItem {
  /// 商品名
  final String name;

  /// カテゴリ名
  final String category;

  /// 紐づく在庫ID
  final String? inventoryId;

  const BuyItem(this.name, this.category, [this.inventoryId]);

  /// 永続化用のキー。カテゴリー名|商品名|在庫ID の形式で保存する
  String get key => '$category|$name|${inventoryId ?? ''}';

  /// 保存されたキー文字列から BuyItem を復元する
  static BuyItem fromKey(String key) {
    final parts = key.split('|');
    if (parts.length >= 3) {
      return BuyItem(parts[1], parts[0], parts[2].isEmpty ? null : parts[2]);
    } else if (parts.length == 2) {
      return BuyItem(parts[1], parts[0]);
    }
    return BuyItem(key, '');
  }
}
