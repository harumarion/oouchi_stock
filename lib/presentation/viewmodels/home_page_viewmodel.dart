import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/buy_item.dart';
import '../../util/firestore_refs.dart';
import '../../util/date_time_parser.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_order.dart';
import '../../domain/entities/buy_list_condition_settings.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/usecases/calculate_days_left.dart';
import '../../domain/usecases/watch_inventory.dart';
import '../../data/repositories/buy_list_repository_impl.dart';
import '../../domain/usecases/add_buy_item.dart';
import '../../data/repositories/buy_prediction_repository_impl.dart';
import '../../domain/usecases/watch_prediction_items.dart';
import '../../domain/usecases/remove_prediction_item.dart';

/// ホーム画面の状態を管理する ViewModel
class HomePageViewModel extends ChangeNotifier {
  /// カテゴリ一覧
  List<Category> categories = [];

  /// 読み込み完了フラグ
  bool categoriesLoaded = false;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _catSub;

  /// 買い物予報条件
  BuyListConditionSettings? conditionSettings;

  final CalculateDaysLeft _calcUsecase =
      CalculateDaysLeft(InventoryRepositoryImpl());
  final WatchInventory _watchInventory = WatchInventory(InventoryRepositoryImpl());
  final AddBuyItem _addBuyItem = AddBuyItem(BuyListRepositoryImpl());
  final _predictionRepo = BuyPredictionRepositoryImpl();
  late final WatchPredictionItems watchPrediction =
      WatchPredictionItems(_predictionRepo);
  late final RemovePredictionItem removePrediction =
      RemovePredictionItem(_predictionRepo);

  /// 買い物リストへ商品を追加するユースケースを公開
  AddBuyItem get addBuyItem => _addBuyItem;

  /// ホーム画面で予報カードの「買い物リストに追加」ボタンを押したときの処理
  Future<void> addPredictionToBuyList(BuyItem item) async {
    final updated = BuyItem(
        item.name, item.category, item.inventoryId, BuyItemReason.prediction);
    await _addBuyItem(updated);
  }

  /// ホーム画面で予報カードをスワイプしたときの削除処理
  Future<void> removePredictionItem(BuyItem item) async {
    await removePrediction(item);
  }

  /// 在庫を監視
  Stream<Inventory?> watchInventory(String id) => _watchInventory(id);

  /// 設定画面から戻った際などにカテゴリリストを更新する
  void updateCategories(List<Category> list) {
    categories = List<Category>.from(list);
    categoriesLoaded = true;
    notifyListeners();
  }

  /// カテゴリ情報を読み込む
  Future<void> loadCategories(List<Category>? initial) async {
    if (initial != null && initial.isNotEmpty) {
      categories = List<Category>.from(initial);
      categories = await applyCategoryOrder(categories);
      categoriesLoaded = true;
      notifyListeners();
    } else {
      _catSub = userCollection('categories')
          .orderBy('createdAt')
          .snapshots()
          .listen((snapshot) async {
        var list = snapshot.docs.map((d) {
          final data = d.data();
          return Category(
            id: data['id'] ?? 0,
            name: data['name'] ?? '',
            createdAt: parseDateTime(data['createdAt']),
          );
        }).toList();
        list = await applyCategoryOrder(list);
        categories = list;
        categoriesLoaded = true;
        notifyListeners();
      });
    }
  }

  /// 買い物予報条件を読み込む
  Future<void> loadCondition() async {
    final s = await loadBuyListConditionSettings();
    conditionSettings = s;
    notifyListeners();
  }

  /// 残り日数を計算
  Future<int> calcDaysLeft(Inventory inv) => _calcUsecase(inv);

  @override
  void dispose() {
    _catSub?.cancel();
    super.dispose();
  }
}
