// Flutter の基本ウィジェットとステート管理を使用
import 'package:flutter/material.dart';

import '../../domain/entities/inventory.dart';
import '../../domain/entities/price_info.dart';
import '../../domain/usecases/add_price_info.dart';
import '../../domain/usecases/fetch_all_inventory.dart';
import '../../data/repositories/price_repository_impl.dart';
import '../../data/repositories/inventory_repository_impl.dart';

/// セール情報追加画面の状態を管理する ViewModel
class AddPriceViewModel extends ChangeNotifier {
  /// セール情報追加ユースケース
  final AddPriceInfo _usecase = AddPriceInfo(PriceRepositoryImpl());
  /// 在庫一覧取得ユースケース
  final FetchAllInventory _fetchInventory =
      FetchAllInventory(InventoryRepositoryImpl());

  /// フォームキー
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// 選択中の在庫
  Inventory? inventory;
  /// 在庫一覧
  List<Inventory> inventories = [];
  /// データ読み込み済みか
  bool loaded = false;

  /// 数量
  double count = 1;
  /// 容量
  double volume = 1;
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

  AddPriceViewModel() {
    _init();
  }

  /// 合計容量計算
  double get totalVolume => count * volume;
  /// 単価計算
  double get unitPrice => totalVolume == 0 ? 0 : salePrice / totalVolume;

  Future<void> _init() async {
    expiry = DateTime.now().add(const Duration(days: 7));
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
  }
}
