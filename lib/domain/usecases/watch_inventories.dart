import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';

class WatchInventories {
  final InventoryRepository repository;
  WatchInventories(this.repository);

  Stream<List<Inventory>> call(String category) {
    return repository.watchByCategory(category);
  }
}
