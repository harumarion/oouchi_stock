// Flutter の基本ウィジェットとステート管理を使用
import 'package:flutter/material.dart';

import '../../domain/entities/inventory.dart';
import '../../domain/entities/price_info.dart';
import '../../domain/usecases/add_price_info.dart';
import '../../domain/usecases/fetch_all_inventory.dart';
import '../../domain/factory/dependency_factory.dart';

/// セール情報追加画面の状態を管理する ViewModel
class AddPriceViewModel extends ChangeNotifier {
  /// DI ファクトリ（セール登録画面で利用する依存を管理）
  final DependencyFactory _factory;

  /// セール情報追加ユースケース
  final AddPriceInfo _usecase;

  /// 在庫一覧取得ユースケース
  final FetchAllInventory _fetchInventory;

  /// フォームキー
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// 選択中の在庫
  Inventory? inventory;
  /// 在庫一覧
  List<Inventory> inventories = [];
  /// データ読み込み済みか
  bool loaded = false;

  /// 数量
  double count = 0;
  /// 容量
  double volume = 0;
  /// 通常価格
  double regularPrice = 0;
  /// セール価格
  double salePrice = 0;
  /// 購入店舗
  String shop = '';
  /// 承認ページURL
  String approvalUrl = '';
  /// メモ
  String memo = '';
  /// セール終了日
  DateTime expiry = DateTime.now();

  AddPriceViewModel({DependencyFactory? factory})
      : _factory = factory ?? DependencyFactory.instance,
        _usecase =
            (factory ?? DependencyFactory.instance).createAddPriceInfo(),
        _fetchInventory =
            (factory ?? DependencyFactory.instance).createFetchAllInventory() {
    _init();
  }

  /// 合計容量計算
  double get totalVolume => count * volume;
  /// 単価計算
  double get unitPrice => totalVolume == 0 ? 0 : salePrice / totalVolume;

  Future<void> _init() async {
    expiry = DateTime.now();
    inventories = await _fetchInventory();
    if (inventories.isNotEmpty) inventory = inventories.first;
    loaded = true;
    notifyListeners();
  }

  /// セール情報保存
  Future<void> save() async {
    if (inventory == null) return;
    final info = PriceInfo(
      id: '',
      inventoryId: inventory!.id,
      checkedAt: DateTime.now(),
      category: inventory!.category,
      itemType: inventory!.itemType,
      itemName: inventory!.itemName,
      count: count,
      unit: inventory!.unit,
      volume: volume,
      totalVolume: totalVolume,
      regularPrice: regularPrice,
      salePrice: salePrice,
      shop: shop,
      approvalUrl: approvalUrl,
      memo: memo,
      unitPrice: unitPrice,
      expiry: expiry,
    );
    await _usecase(info);
    // セール情報登録後、買い物予報・買い物リストへの自動追加を評価
    final settings = await _factory.loadPurchaseDecisionSettings();
    final decision = _factory.createPurchaseDecision(
      threshold: 2,
      settings: settings,
    );
    final prediction =
        _factory.createAutoAddPredictionItem(decision);
    await prediction(inventory!, info);
    // セール登録後、買い物リストへの自動追加も評価
    final buy = _factory.createAutoAddBuyItem(decision);
    await buy(inventory!, info);
  }
}
