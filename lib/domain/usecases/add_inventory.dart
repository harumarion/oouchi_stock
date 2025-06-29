import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';

/// 在庫を新規追加するユースケース

class AddInventory {
  /// データ保存先リポジトリ
  final InventoryRepository repository;

  AddInventory(this.repository);

  Future<void> call(Inventory inventory) async {
    await repository.addInventory(inventory);
  }
}
