import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/buy_list_repository_impl.dart';
import '../../data/repositories/buy_prediction_repository_impl.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../data/repositories/price_repository_impl.dart';
import '../../domain/entities/buy_item.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/entities/purchase_decision_settings.dart';
import '../../domain/usecases/add_buy_item.dart';
import '../../domain/usecases/add_prediction_item.dart';
import '../../domain/usecases/auto_add_buy_item.dart';
import '../../domain/usecases/auto_add_prediction_item.dart';
import '../../domain/usecases/delete_inventory_with_relations.dart';
import '../../domain/usecases/purchase_decision.dart';
import '../../domain/usecases/stocktake.dart';
import '../../domain/usecases/update_quantity.dart';
import '../../domain/usecases/watch_inventories.dart';
import '../../domain/usecases/watch_inventory.dart';
import '../../domain/usecases/watch_price_by_type.dart';

/// 在庫一覧の1タブ分の状態を管理する ViewModel
/// 検索バーやスワイプ削除など、在庫一覧画面の操作を集約する
class InventoryListViewModel extends ChangeNotifier {
  /// 表示対象カテゴリ名
  final String category;

  /// 在庫取得ユースケース
  final WatchInventories _watch;

  /// 在庫削除ユースケース
  final DeleteInventoryWithRelations _delete;

  /// 買い物リスト追加ユースケース
  final AddBuyItem _addBuy;

  /// 在庫数量更新ユースケース
  final UpdateQuantity _updateQuantity;

  /// 棚卸し登録ユースケース
  final Stocktake _stocktake;

  /// 検索・フィルタ処理のディレイ
  final Duration _debounceDuration;

  /// 検索文字列
  String search = '';

  /// 検索バーのコントローラ
  final SearchController controller = SearchController();

  /// 最新の取得結果
  List<Inventory> _rawItems = const [];

  /// フィルタ後の一覧
  List<Inventory> _filteredItems = const [];

  /// Firestore 取得中かどうか
  bool _loading = true;

  /// 読み込み失敗時のメッセージ
  String? _errorMessage;

  StreamSubscription<List<Inventory>>? _subscription;
  Timer? _debounceTimer;

  InventoryListViewModel({
    required this.category,
    WatchInventories? watch,
    DeleteInventoryWithRelations? delete,
    AddBuyItem? addBuy,
    UpdateQuantity? updateQuantity,
    Stocktake? stocktake,
    Duration debounceDuration = const Duration(milliseconds: 160),
  })  : _watch = watch ?? WatchInventories(InventoryRepositoryImpl()),
        _delete = delete ??
            DeleteInventoryWithRelations(
              InventoryRepositoryImpl(),
              PriceRepositoryImpl(),
              BuyListRepositoryImpl(),
              BuyPredictionRepositoryImpl(),
            ),
        _addBuy = addBuy ?? AddBuyItem(BuyListRepositoryImpl()),
        _updateQuantity = updateQuantity ?? UpdateQuantity(InventoryRepositoryImpl()),
        _stocktake = stocktake ?? Stocktake(InventoryRepositoryImpl()),
        _debounceDuration = debounceDuration {
    _startWatch();
  }

  /// 表示用の在庫リスト
  UnmodifiableListView<Inventory> get filteredItems =>
      UnmodifiableListView(_filteredItems);

  /// データ取得中かどうか
  bool get loading => _loading;

  /// エラー文言
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
      onError: (Object error, StackTrace stackTrace) {
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

    final query = search.trim().toLowerCase();
    final filtered = _rawItems.where((inv) {
      if (query.isEmpty) {
        return true;
      }
      return inv.itemName.toLowerCase().contains(query) ||
          inv.category.toLowerCase().contains(query) ||
          inv.itemType.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (!listEquals(filtered, _filteredItems)) {
      _filteredItems = filtered;
    }
    notifyListeners();
  }

  /// 在庫一覧画面の検索バーから呼び出される
  void setSearch(String value) {
    search = value;
    _applyFilters();
  }

  /// 在庫を買い物リストへ追加
  Future<void> addToBuyList(Inventory inv) async {
    await _addBuy(
      BuyItem(inv.itemName, inv.category, inv.id, BuyItemReason.inventory),
    );
  }

  /// 在庫数量を更新
  Future<void> updateQuantity(String id, double amount, String type) async {
    await _updateQuantity(id, amount, type);
    try {
      final inv = await WatchInventory(InventoryRepositoryImpl())(id).first;
      if (inv == null) return;
      final prices = await WatchPriceByType(PriceRepositoryImpl())(
        inv.category,
        inv.itemType,
      ).first;
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
  Future<void> stocktake(
    String id,
    double before,
    double after,
    double diff,
  ) async {
    await _stocktake(id, before, after, diff);
    try {
      final inv = await WatchInventory(InventoryRepositoryImpl())(id).first;
      if (inv == null) return;
      final prices = await WatchPriceByType(PriceRepositoryImpl())(
        inv.category,
        inv.itemType,
      ).first;
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
    await _delete(id);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    controller.dispose();
    super.dispose();
  }
}
