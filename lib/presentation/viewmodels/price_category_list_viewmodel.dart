import 'package:flutter/material.dart';
import '../../data/repositories/price_repository_impl.dart';
import '../../domain/entities/price_info.dart';
import '../../domain/usecases/watch_price_by_category.dart';

/// セール情報管理画面のカテゴリタブを管理する ViewModel
class PriceCategoryListViewModel extends ChangeNotifier {
  final String category;
  final WatchPriceByCategory _watch;

  PriceCategoryListViewModel({required this.category, WatchPriceByCategory? watch})
      : _watch = watch ?? WatchPriceByCategory(PriceRepositoryImpl());

  /// 検索文字列
  String search = '';

  /// 並び替え条件
  String sort = 'updated';

  /// 期限切れを表示するか
  bool showExpired = false;

  /// 入力コントローラー
  final TextEditingController controller = TextEditingController();

  /// セール情報ストリーム
  Stream<List<PriceInfo>> get stream => _watch(category);

  /// 検索文字列を更新
  void setSearch(String v) {
    search = v;
    notifyListeners();
  }

  /// 並び替え条件を更新
  void setSort(String v) {
    sort = v;
    notifyListeners();
  }

  /// 期限切れ表示設定を更新
  void setShowExpired(bool v) {
    showExpired = v;
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
