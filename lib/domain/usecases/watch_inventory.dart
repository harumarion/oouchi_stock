import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';

class WatchInventory {
  final InventoryRepository repository;
  WatchInventory(this.repository);

  Stream<Inventory?> call(String id) {
    return repository.watchInventory(id);
  }
}
