import '../../domain/repositories/inventory_repository.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/entities/history_entry.dart';
import '../../data/repositories/inventory_repository_impl.dart';

/// 在庫詳細画面の状態を管理する ViewModel
class InventoryDetailViewModel {
  final String inventoryId;
  final InventoryRepository repository;

  InventoryDetailViewModel({required this.inventoryId, InventoryRepository? repository})
      : repository = repository ?? InventoryRepositoryImpl();

  /// 在庫を監視するストリーム
  Stream<Inventory?> inventoryStream() => repository.watchInventory(inventoryId);

  /// 履歴を監視するストリーム
  Stream<List<HistoryEntry>> historyStream() => repository.watchHistory(inventoryId);
}
