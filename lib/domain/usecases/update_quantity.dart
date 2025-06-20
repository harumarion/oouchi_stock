import '../repositories/inventory_repository.dart';

/// 数量を変更するユースケース

class UpdateQuantity {
  /// 在庫更新に利用するリポジトリ
  final InventoryRepository repository;

  UpdateQuantity(this.repository);

  Future<void> call(String id, double amount, String type) async {
    await repository.updateQuantity(id, amount, type);
  }
}
