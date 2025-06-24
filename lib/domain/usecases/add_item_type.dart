import '../entities/item_type.dart';
import '../repositories/item_type_repository.dart';

/// 品種を新規追加するユースケース
class AddItemType {
  /// データ保存先リポジトリ
  final ItemTypeRepository repository;

  AddItemType(this.repository);

  /// 品種を保存する
  Future<void> call(ItemType itemType) async {
    await repository.addItemType(itemType);
  }
}
