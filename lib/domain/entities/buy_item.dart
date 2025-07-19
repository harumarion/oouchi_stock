/// 買い物リストの1項目を表すエンティティ
/// [inventoryId] が存在する場合、在庫データとの関連を示す

/// 追加理由を表す列挙型
enum BuyItemReason {
  /// 手動追加
  manual,
  /// 在庫画面から追加
  inventory,
  /// セール管理から追加
  sale,
  /// 予報画面から追加
  prediction,
  /// 在庫ゼロによる自動追加
  autoEmergency,
  /// 買い時判定による自動追加
  autoBestTime,
  /// 残り日数不足による自動追加
  autoCautious,
  /// まとめ買い推奨による自動追加
  autoBulk,
}

/// 買い物リストの1項目を表すエンティティ
/// [inventoryId] が存在する場合、在庫データとの関連を示す
class BuyItem {
  /// 商品名
  final String name;

  /// カテゴリ名
  final String category;

  /// 紐づく在庫ID
  final String? inventoryId;

  /// 追加理由
  final BuyItemReason reason;

  const BuyItem(
    this.name,
    this.category, [
    this.inventoryId,
    this.reason = BuyItemReason.manual,
  ]);

  /// 永続化用のキー。カテゴリー名|商品名|在庫ID|理由 の形式で保存する
  String get key => '$category|$name|${inventoryId ?? ''}|${reason.name}';

  /// 保存されたキー文字列から BuyItem を復元する
  static BuyItem fromKey(String key) {
    final parts = key.split('|');
    BuyItemReason r = BuyItemReason.manual;
    if (parts.length >= 4) {
      r = BuyItemReason.values
          .firstWhere((e) => e.name == parts[3], orElse: () => BuyItemReason.manual);
    }
    if (parts.length >= 3) {
      return BuyItem(
        parts[1],
        parts[0],
        parts[2].isEmpty ? null : parts[2],
        r,
      );
    } else if (parts.length == 2) {
      return BuyItem(parts[1], parts[0], null, r);
    }
    return BuyItem(key, '', null, r);
  }
}
