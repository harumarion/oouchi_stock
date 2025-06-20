import '../entities/history_entry.dart';
import '../repositories/inventory_repository.dart';

/// 履歴を監視するユースケース

class WatchHistory {
  /// データ取得元リポジトリ
  final InventoryRepository repository;

  WatchHistory(this.repository);

  Stream<List<HistoryEntry>> call(String inventoryId) {
    return repository.watchHistory(inventoryId);
  }
}
