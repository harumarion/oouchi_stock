import '../entities/item_type.dart';

/// Firestore上の品種データを扱うリポジトリ
abstract class ItemTypeRepository {
  /// 品種を追加してIDを返す
  Future<String> addItemType(ItemType itemType);

  /// 既存の品種を更新する
  Future<void> updateItemType(ItemType itemType);
}
