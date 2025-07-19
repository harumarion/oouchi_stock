import 'package:flutter/material.dart';
import '../../data/repositories/buy_list_repository_impl.dart';
import '../../domain/entities/buy_item.dart';
import '../../domain/usecases/add_buy_item.dart';
import '../../models/sale_item.dart';

/// 買い得リスト画面の状態を管理する ViewModel
class SaleListViewModel extends ChangeNotifier {
  /// 表示するセール情報一覧（現在は未使用のため空リスト）
  final List<SaleItem> items = [];

  /// 通知オン/オフ
  bool notify = true;

  /// 並び替え条件
  String sort = 'end';

  /// 検索文字列
  String search = '';

  /// 検索バーのコントローラ
  final SearchController controller = SearchController();

  final AddBuyItem addBuyItem = AddBuyItem(BuyListRepositoryImpl());

  /// セール一覧画面で「買い物リストに追加」ボタンを押したときの処理
  /// [item] 追加する買い物リストアイテム
  Future<void> addToBuyList(BuyItem item) async {
    await addBuyItem(item);
  }

  /// 並び替え後のリストを取得
  List<SaleItem> get sortedItems {
    final sorted = List<SaleItem>.from(items);
    sorted.sort((a, b) {
      if (sort == 'discount') {
        final ad = (a.regularPrice - a.salePrice) / a.regularPrice;
        final bd = (b.regularPrice - b.salePrice) / b.regularPrice;
        return bd.compareTo(ad);
      } else if (sort == 'unit') {
        return a.salePrice.compareTo(b.salePrice);
      } else if (sort == 'recommend') {
        if (a.recommended == b.recommended) return 0;
        return a.recommended ? -1 : 1;
      }
      return a.end.compareTo(b.end);
    });
    return sorted;
  }

  /// 検索結果を取得
  List<SaleItem> get filteredItems =>
      sortedItems
          .where((e) => e.name.contains(search) || e.itemType.contains(search))
          .toList();

  /// 並び替え条件を更新
  void updateSort(String value) {
    sort = value;
    notifyListeners();
  }

  /// 通知設定を更新
  void updateNotify(bool value) {
    notify = value;
    notifyListeners();
  }

  /// 検索文字列を更新
  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
