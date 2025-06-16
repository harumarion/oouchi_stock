import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';

/// 単一の在庫を監視するユースケース

class WatchInventory {
  final InventoryRepository repository;
  WatchInventory(this.repository);

  Stream<Inventory?> call(String id) {
    return repository.watchInventory(id);
  }
}
