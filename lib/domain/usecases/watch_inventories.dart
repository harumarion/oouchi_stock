import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';

/// カテゴリの在庫を監視するユースケース

class WatchInventories {
  /// データ取得元リポジトリ
  final InventoryRepository repository;

  WatchInventories(this.repository);

  Stream<List<Inventory>> call(String category) {
    return repository.watchByCategory(category);
  }
}
