import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';

class FetchAllInventory {
  final InventoryRepository repository;
  FetchAllInventory(this.repository);

  Future<List<Inventory>> call() {
    return repository.fetchAll();
  }
}
