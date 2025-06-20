import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';

/// 残量が一定以下の在庫を監視するユースケース
class WatchLowInventory {
  /// データ取得元リポジトリ
  final InventoryRepository repository;

  WatchLowInventory(this.repository);

  Stream<List<Inventory>> call(double threshold) {
    return repository.watchNeedsBuy(threshold);
  }
}
