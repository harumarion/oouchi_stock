import '../entities/history_entry.dart';
import '../repositories/inventory_repository.dart';

class WatchHistory {
  final InventoryRepository repository;
  WatchHistory(this.repository);

  Stream<List<HistoryEntry>> call(String inventoryId) {
    return repository.watchHistory(inventoryId);
  }
}
