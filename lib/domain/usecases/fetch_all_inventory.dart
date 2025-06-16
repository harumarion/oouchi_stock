import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';

/// すべての在庫を取得するユースケース

class FetchAllInventory {
  final InventoryRepository repository;
  FetchAllInventory(this.repository);

  Future<List<Inventory>> call() {
    return repository.fetchAll();
  }
}
