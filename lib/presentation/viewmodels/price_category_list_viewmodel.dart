import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/buy_item.dart';
import '../../domain/entities/price_info.dart';
import '../../domain/usecases/add_buy_item.dart';
import '../../domain/usecases/delete_price_info.dart';
import '../../domain/usecases/watch_price_by_category.dart';
import '../../domain/factory/dependency_factory.dart';

/// セール情報管理画面のカテゴリタブを管理する ViewModel
class PriceCategoryListViewModel extends ChangeNotifier {
  /// DI ファクトリ（セールカテゴリ画面で利用する依存を集約）
  final DependencyFactory _factory;
  /// 対象カテゴリ名
  final String category;

  /// セール情報監視用ユースケース
  final WatchPriceByCategory _watch;

  /// セール情報削除用ユースケース
  final DeletePriceInfo _delete;

  /// 買い物リスト追加ユースケース
  final AddBuyItem _addBuy;

  /// フィルタリングを遅延させる待ち時間
  final Duration _debounceDuration;

  /// 検索文字列
  String search = '';

  /// 並び替え条件
  String sort = 'updated';

  /// 期限切れを表示するか
  bool showExpired = false;

  /// 入力コントローラー
  final SearchController controller = SearchController();

  /// 最新の取得結果
  List<PriceInfo> _rawItems = const [];

  /// フィルタ後の一覧
  List<PriceInfo> _filteredItems = const [];

  /// Firestore 取得中かどうか
  bool _loading = true;

  /// エラーメッセージ
  String? _errorMessage;

  StreamSubscription<List<PriceInfo>>? _subscription;
  Timer? _debounceTimer;

  PriceCategoryListViewModel({
    required this.category,
    WatchPriceByCategory? watch,
    DeletePriceInfo? delete,
    AddBuyItem? addBuy,
    Duration debounceDuration = const Duration(milliseconds: 160),
    DependencyFactory? factory,
  })  : _factory = factory ?? DependencyFactory.instance,
        _watch = watch ??
            (factory ?? DependencyFactory.instance)
                .createWatchPriceByCategory(),
        _delete = delete ??
            (factory ?? DependencyFactory.instance).createDeletePriceInfo(),
        _addBuy = addBuy ??
            (factory ?? DependencyFactory.instance).createAddBuyItem(),
        _debounceDuration = debounceDuration {
    _startWatch();
  }

  /// 表示用の一覧を取得
  UnmodifiableListView<PriceInfo> get filteredItems =>
      UnmodifiableListView(_filteredItems);

  /// データ取得中かどうか
  bool get loading => _loading;

  /// 読み込みエラー内容
  String? get errorMessage => _errorMessage;

  void _startWatch() {
    _subscription?.cancel();
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    _subscription = _watch(category).listen(
      (items) {
        _rawItems = items;
        _loading = false;
        _errorMessage = null;
        _applyFilters(immediate: true);
      },
      onError: (Object error, StackTrace stack) {
        _loading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void _applyFilters({bool immediate = false}) {
    if (!immediate) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceDuration, () => _applyFilters(immediate: true));
      return;
    }

    final now = DateTime.now();
    final query = search.trim().toLowerCase();
    final filtered = _rawItems.where((info) {
      if (!showExpired && info.expiry
          .isBefore(now.subtract(const Duration(days: 1)))) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return info.itemName.toLowerCase().contains(query) ||
          info.category.toLowerCase().contains(query) ||
          info.itemType.toLowerCase().contains(query);
    }).toList();

    switch (sort) {
      case 'alphabet':
        filtered.sort((a, b) => a.itemType.compareTo(b.itemType));
        break;
      case 'unitPrice':
        filtered.sort((a, b) => a.unitPrice.compareTo(b.unitPrice));
        break;
      default:
        filtered.sort((a, b) => b.checkedAt.compareTo(a.checkedAt));
        break;
    }

    if (!listEquals(filtered, _filteredItems)) {
      _filteredItems = filtered;
    }
    notifyListeners();
  }

  /// セール情報管理画面の検索バーから呼び出される
  void setSearch(String v) {
    search = v;
    _applyFilters();
  }

  /// 並び替え条件を更新
  void setSort(String v) {
    sort = v;
    _applyFilters(immediate: true);
  }

  /// 期限切れ表示設定を更新
  void setShowExpired(bool v) {
    showExpired = v;
    _applyFilters(immediate: true);
  }

  /// セール情報を削除
  Future<void> delete(String id) async {
    await _delete(id);
  }

  /// カードのボタンから呼ばれ、買い物リストに追加する
  Future<void> addToBuyList(PriceInfo info) async {
    final item = _factory.createBuyItem(
      info.itemName,
      info.itemType,
      null,
      BuyItemReason.sale,
    );
    await _addBuy(item);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    controller.dispose();
    super.dispose();
  }
}
