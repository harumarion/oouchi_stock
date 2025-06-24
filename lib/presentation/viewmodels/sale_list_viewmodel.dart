import 'package:flutter/material.dart';
import '../../data/repositories/buy_list_repository_impl.dart';
import '../../domain/entities/buy_item.dart';
import '../../domain/usecases/add_buy_item.dart';
import '../../models/sale_item.dart';

/// 買い得リスト画面の状態を管理する ViewModel
class SaleListViewModel extends ChangeNotifier {
  /// 表示するセール情報一覧
  final List<SaleItem> items = [
    SaleItem(
      name: 'コーヒー豆 200g',
      shop: 'Amazon',
      regularPrice: 1200,
      salePrice: 980,
      start: DateTime.now().subtract(const Duration(days: 1)),
      end: DateTime.now().add(const Duration(days: 2)),
      stock: 5,
      recommended: true,
      lowest: true,
    ),
    SaleItem(
      name: 'トイレットペーパー 12ロール',
      shop: '楽天',
      regularPrice: 600,
      salePrice: 480,
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 5)),
      stock: 20,
    ),
    SaleItem(
      name: '洗剤 詰め替え用',
      shop: '近所のスーパー',
      regularPrice: 350,
      salePrice: 300,
      start: DateTime.now().subtract(const Duration(days: 2)),
      end: DateTime.now().add(const Duration(days: 1)),
      stock: 1,
    ),
  ];

  /// 通知オン/オフ
  bool notify = true;

  /// 並び替え条件
  String sort = 'end';

  final AddBuyItem addBuyItem = AddBuyItem(BuyListRepositoryImpl());

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
}
