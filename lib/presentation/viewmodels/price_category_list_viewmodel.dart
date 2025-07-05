import 'package:flutter/material.dart';
import '../../data/repositories/price_repository_impl.dart';
import '../../domain/entities/price_info.dart';
import '../../domain/usecases/watch_price_by_category.dart';
import '../../domain/usecases/delete_price_info.dart';

/// セール情報管理画面のカテゴリタブを管理する ViewModel
class PriceCategoryListViewModel extends ChangeNotifier {
  /// 対象カテゴリ名
  final String category;
  /// セール情報監視用ユースケース
  final WatchPriceByCategory _watch;
  /// セール情報削除用ユースケース
  final DeletePriceInfo _delete;

  PriceCategoryListViewModel({
    required this.category,
    WatchPriceByCategory? watch,
    DeletePriceInfo? delete,
  })  : _watch = watch ?? WatchPriceByCategory(PriceRepositoryImpl()),
        _delete = delete ?? DeletePriceInfo(PriceRepositoryImpl());

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

  /// セール情報を削除
  Future<void> delete(String id) async {
    await _delete(id);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
