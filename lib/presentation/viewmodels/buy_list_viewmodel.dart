import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/buy_item.dart';
import '../../domain/entities/buy_list_condition_settings.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_order.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/services/buy_list_strategy.dart';
import '../../domain/usecases/add_buy_item.dart';
import '../../domain/usecases/remove_buy_item.dart';
import '../../domain/usecases/watch_buy_items.dart';
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

  /// 追加テキスト入力用コントローラ
  final TextEditingController itemController = TextEditingController();

  /// カテゴリ一覧
  List<Category> categories = [];
  /// 読み込み済みかどうか
  bool loaded = false;
  /// 条件設定
  BuyListConditionSettings? condition;

  StreamSubscription<List<Inventory>>? _invSub;

  BuyListViewModel({
    required this.repository,
    required this.addUsecase,
    required this.removeUsecase,
    required this.watchUsecase,
  });

  /// 買い物リストストリーム
  Stream<List<BuyItem>> get stream => watchUsecase();

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
    loaded = true;
    notifyListeners();
    final strategy = createStrategy(condition!);
    _invSub = strategy.watch(repository).listen((list) {
      for (final inv in list) {
        addUsecase(BuyItem(inv.itemName, inv.category, inv.id));
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
    await addUsecase(BuyItem(text, ''));
    itemController.clear();
  }

  /// アイテム削除処理
  Future<void> removeItem(BuyItem item) async {
    await removeUsecase(item);
  }

  @override
  void dispose() {
    _invSub?.cancel();
    itemController.dispose();
    super.dispose();
  }
}
