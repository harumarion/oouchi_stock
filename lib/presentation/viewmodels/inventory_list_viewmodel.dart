import 'package:flutter/material.dart';

import '../../domain/entities/inventory.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/buy_item.dart';
import '../../domain/usecases/watch_inventories.dart';
import '../../domain/usecases/delete_inventory.dart';
import '../../domain/usecases/add_buy_item.dart';
import '../../domain/usecases/update_quantity.dart';
import '../../domain/usecases/stocktake.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../data/repositories/buy_list_repository_impl.dart';

/// 在庫一覧の1タブ分の状態を管理する ViewModel
/// 検索ワードや並び替え条件を保持し、在庫データのストリームを提供する
class InventoryListViewModel extends ChangeNotifier {
  /// 表示対象カテゴリ名
  final String category;
  final WatchInventories watchUsecase =
      WatchInventories(InventoryRepositoryImpl());
  final DeleteInventory deleteUsecase =
      DeleteInventory(InventoryRepositoryImpl());
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
  }

  /// 棚卸しを記録
  Future<void> stocktake(String id, double before, double after, double diff) async {
    await stocktakeUsecase(id, before, after, diff);
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
