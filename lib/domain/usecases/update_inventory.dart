import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';

/// 在庫情報を更新するユースケース

class UpdateInventory {
  final InventoryRepository repository;
  UpdateInventory(this.repository);

  Future<void> call(Inventory inventory) async {
    await repository.updateInventory(inventory);
  }
}
