import 'dart:async';
import 'package:flutter/material.dart';

import '../../domain/entities/buy_item.dart';
import '../../domain/entities/buy_list_condition_settings.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_order.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/buy_list_repository.dart';
import '../../domain/usecases/add_buy_item.dart';
import '../../domain/usecases/remove_buy_item.dart';
import '../../domain/usecases/watch_buy_items.dart';
import '../../domain/usecases/update_quantity.dart';
import '../../domain/usecases/watch_inventory.dart';
import '../../domain/usecases/calculate_days_left.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../data/repositories/buy_list_repository_impl.dart';
import '../../util/date_time_parser.dart';
import '../../util/firestore_refs.dart';

/// 買い物予報画面の状態を管理する ViewModel
/// カテゴリ読み込みや条件設定、リスト操作を担当する
class BuyListViewModel extends ChangeNotifier {
  /// 在庫リポジトリ
  final InventoryRepository repository;
  /// 買い物リスト追加ユースケース
  final AddBuyItem addUsecase;
  /// 買い物リスト削除ユースケース
  final RemoveBuyItem removeUsecase;
  /// 買い物リスト監視ユースケース
  final WatchBuyItems watchUsecase;
  /// 在庫数量更新ユースケース
  final UpdateQuantity _updateQuantity;
  /// 在庫監視ユースケース
  final WatchInventory _watchInventory;
  /// 残り日数計算ユースケース
  final CalculateDaysLeft _calcDaysLeft;

  /// 買い物リストを保存するリポジトリ
  final BuyListRepository _buyRepository;

  /// 追加テキスト入力用コントローラ
  final TextEditingController itemController = TextEditingController();

  /// カテゴリ一覧
  List<Category> categories = [];
  /// 読み込み済みかどうか
  bool loaded = false;
  /// 条件設定
  BuyListConditionSettings? condition;


  StreamSubscription<List<Inventory>>? _invSub;

  /// 手動削除した在庫ID一覧
  Set<String> _ignoredIds = {};

  factory BuyListViewModel({
    InventoryRepository? repository,
    BuyListRepository? buyRepository,
    AddBuyItem? addUsecase,
    RemoveBuyItem? removeUsecase,
    WatchBuyItems? watchUsecase,
    UpdateQuantity? updateQuantity,
    WatchInventory? watchInventory,
    CalculateDaysLeft? calcDaysLeft,
  }) {
    final invRepo = repository ?? InventoryRepositoryImpl();
    final buyRepo = buyRepository ?? BuyListRepositoryImpl();
    return BuyListViewModel._(
      repository: invRepo,
      buyRepository: buyRepo,
      addUsecase: addUsecase ?? AddBuyItem(buyRepo),
      removeUsecase: removeUsecase ?? RemoveBuyItem(buyRepo),
      watchUsecase: watchUsecase ?? WatchBuyItems(buyRepo),
      updateQuantity: updateQuantity ?? UpdateQuantity(invRepo),
      watchInventory: watchInventory ?? WatchInventory(invRepo),
      calcDaysLeft: calcDaysLeft ?? CalculateDaysLeft(invRepo),
    );
  }

  BuyListViewModel._({
    required this.repository,
    required BuyListRepository buyRepository,
    required this.addUsecase,
    required this.removeUsecase,
    required this.watchUsecase,
    required UpdateQuantity updateQuantity,
    required WatchInventory watchInventory,
    required CalculateDaysLeft calcDaysLeft,
  })  : _buyRepository = buyRepository,
        _updateQuantity = updateQuantity,
        _watchInventory = watchInventory,
        _calcDaysLeft = calcDaysLeft;

  /// 買い物リストストリーム
  Stream<List<BuyItem>> get stream => watchUsecase();

  /// 手動削除した在庫ID一覧を読み込む
  Future<void> _loadIgnored() async {
    final ids = await _buyRepository.loadIgnoredIds();
    _ignoredIds = ids.toSet();
  }

  /// 初期データを読み込む
  Future<void> load({List<Category>? initialCategories}) async {
    await _invSub?.cancel();
    if (initialCategories != null && initialCategories.isNotEmpty) {
      categories = await applyCategoryOrder(List<Category>.from(initialCategories));
    } else {
      final snapshot = await userCollection('categories')
          .orderBy('createdAt')
          .get();
      categories = snapshot.docs.map((d) {
        final data = d.data();
        return Category(
          id: data['id'] ?? 0,
          name: data['name'] ?? '',
          createdAt: parseDateTime(data['createdAt']),
          color: data['color'],
        );
      }).toList();
      categories = await applyCategoryOrder(categories);
    }
    condition = await loadBuyListConditionSettings();
    // 在庫一覧の監視に備えて手動削除IDを読み込み
    await _loadIgnored();
    loaded = true;
    notifyListeners();
    final strategy = createStrategy(condition!);
    // 条件に合致した在庫を監視し、買い物リストへ自動追加
    _invSub = strategy.watch(repository).listen((list) async {
      for (final inv in list) {
        if (_ignoredIds.contains(inv.id)) continue;
        await addUsecase(BuyItem(
            inv.itemName, inv.category, inv.id, BuyItemReason.autoCautious));
      }
    });
  }

  /// カテゴリ更新処理
  void updateCategories(List<Category> list) {
    categories = List<Category>.from(list);
    notifyListeners();
  }

  /// 再読み込み処理
  Future<void> refresh() async {
    loaded = false;
    notifyListeners();
    await load();
  }

  /// 手動追加処理
  Future<void> addManualItem() async {
    final text = itemController.text.trim();
    if (text.isEmpty) return;
    await addUsecase(BuyItem(text, '', null, BuyItemReason.manual));
    itemController.clear();
  }

  /// 在庫詳細画面やカード操作で数量を変更したときに呼ばれる
  Future<void> updateQuantity(String id, double amount, String type) async {
    await _updateQuantity(id, amount, type);
    await _buyRepository.removeIgnoredId(id);
    _ignoredIds.remove(id);
  }

  /// 在庫を監視
  Stream<Inventory?> watchInventory(String id) => _watchInventory(id);

  /// 残り日数を計算
  Future<int> calcDaysLeft(Inventory inv) => _calcDaysLeft(inv);

  /// BuyListPage でカードをスワイプして削除したときの処理
  Future<void> removeItem(BuyItem item) async {
    await removeUsecase(item);
    if (item.inventoryId != null) {
      await _buyRepository.addIgnoredId(item.inventoryId!);
      _ignoredIds.add(item.inventoryId!);
    }
  }

  @override
  void dispose() {
    _invSub?.cancel();
    itemController.dispose();
    super.dispose();
  }
}
