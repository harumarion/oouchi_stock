import '../entities/item_type.dart';
import '../repositories/item_type_repository.dart';

/// 品種を更新するユースケース
class UpdateItemType {
  /// 利用するリポジトリ
  final ItemTypeRepository repository;

  UpdateItemType(this.repository);

  /// 品種を更新
  Future<void> call(ItemType itemType) async {
    await repository.updateItemType(itemType);
  }
}
