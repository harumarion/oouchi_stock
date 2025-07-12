import 'package:flutter/material.dart';

import '../../domain/entities/inventory.dart';
import '../../domain/entities/buy_item.dart';
import '../../domain/usecases/watch_inventories.dart';
import '../../domain/usecases/delete_inventory_with_relations.dart';
import '../../domain/usecases/add_buy_item.dart';
import '../../domain/usecases/update_quantity.dart';
import '../../domain/usecases/stocktake.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../data/repositories/buy_list_repository_impl.dart';
import '../../data/repositories/price_repository_impl.dart';
import '../../data/repositories/buy_prediction_repository_impl.dart';
import '../../domain/usecases/watch_inventory.dart';
import '../../domain/usecases/watch_price_by_type.dart';
import '../../domain/usecases/add_prediction_item.dart';
import '../../domain/usecases/auto_add_prediction_item.dart';
import '../../domain/usecases/auto_add_buy_item.dart';
import '../../domain/usecases/purchase_decision.dart';
import '../../domain/entities/purchase_decision_settings.dart';

/// 在庫一覧の1タブ分の状態を管理する ViewModel
/// 検索ワードや並び替え条件を保持し、在庫データのストリームを提供する
class InventoryListViewModel extends ChangeNotifier {
  /// 表示対象カテゴリ名
  final String category;
  final WatchInventories watchUsecase =
      WatchInventories(InventoryRepositoryImpl());
  final DeleteInventoryWithRelations deleteUsecase = DeleteInventoryWithRelations(
    InventoryRepositoryImpl(),
    PriceRepositoryImpl(),
    BuyListRepositoryImpl(),
    BuyPredictionRepositoryImpl(),
  );
  final AddBuyItem addUsecase = AddBuyItem(BuyListRepositoryImpl());
  final UpdateQuantity updateQuantityUsecase =
      UpdateQuantity(InventoryRepositoryImpl());
  final Stocktake stocktakeUsecase =
      Stocktake(InventoryRepositoryImpl());

  /// 検索文字列
  String search = '';

  /// 並び替え条件 ('alphabet' または 'updated')
  String sort = 'updated';

  /// 検索バーのコントローラ
  final TextEditingController controller = TextEditingController();

  InventoryListViewModel({required this.category});

  /// 在庫ストリームを取得
  Stream<List<Inventory>> get stream => watchUsecase(category);

  /// 検索文字列を更新
  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  /// 並び替え条件を更新
  void setSort(String value) {
    sort = value;
    notifyListeners();
  }

  /// 在庫を買い物リストへ追加
  Future<void> addToBuyList(Inventory inv) async {
    await addUsecase(BuyItem(inv.itemName, inv.category, inv.id));
  }

  /// 在庫数量を更新
  Future<void> updateQuantity(String id, double amount, String type) async {
    await updateQuantityUsecase(id, amount, type);
    try {
      final inv = await WatchInventory(InventoryRepositoryImpl())(id).first;
      if (inv == null) return;
      final prices = await WatchPriceByType(PriceRepositoryImpl())(inv.category, inv.itemType).first;
      final price = prices.isNotEmpty ? prices.first : null;
      final settings = await loadPurchaseDecisionSettings();
      final prediction = AutoAddPredictionItem(
        AddPredictionItem(BuyPredictionRepositoryImpl()),
        PurchaseDecision(
          2,
          cautiousDays: settings.cautiousDays,
          bestTimeDays: settings.bestTimeDays,
          discountPercent: settings.discountPercent,
        ),
      );
      await prediction(inv, price);
      // 在庫一覧画面で数量を変更した後、買い物リストへの自動追加も評価
      final buy = AutoAddBuyItem(
        AddBuyItem(BuyListRepositoryImpl()),
        PurchaseDecision(
          2,
          cautiousDays: settings.cautiousDays,
          bestTimeDays: settings.bestTimeDays,
          discountPercent: settings.discountPercent,
        ),
      );
      await buy(inv, price);
    } catch (e) {
      // 自動追加失敗時はログのみ
      debugPrint('auto add prediction failed: $e');
    }
  }

  /// 棚卸しを記録
  Future<void> stocktake(String id, double before, double after, double diff) async {
    await stocktakeUsecase(id, before, after, diff);
    try {
      final inv = await WatchInventory(InventoryRepositoryImpl())(id).first;
      if (inv == null) return;
      final prices = await WatchPriceByType(PriceRepositoryImpl())(inv.category, inv.itemType).first;
      final price = prices.isNotEmpty ? prices.first : null;
      final settings = await loadPurchaseDecisionSettings();
      final prediction = AutoAddPredictionItem(
        AddPredictionItem(BuyPredictionRepositoryImpl()),
        PurchaseDecision(
          2,
          cautiousDays: settings.cautiousDays,
          bestTimeDays: settings.bestTimeDays,
          discountPercent: settings.discountPercent,
        ),
      );
      await prediction(inv, price);
      // 棚卸し後も買い物リストへの自動追加を評価
      final buy = AutoAddBuyItem(
        AddBuyItem(BuyListRepositoryImpl()),
        PurchaseDecision(
          2,
          cautiousDays: settings.cautiousDays,
          bestTimeDays: settings.bestTimeDays,
          discountPercent: settings.discountPercent,
        ),
      );
      await buy(inv, price);
    } catch (e) {
      debugPrint('auto add prediction failed: $e');
    }
  }

  /// 在庫を削除
  Future<void> delete(String id) async {
    await deleteUsecase(id);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
