import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';
import 'package:oouchi_stock/domain/repositories/inventory_repository.dart';
import 'package:oouchi_stock/domain/repositories/price_repository.dart';
import 'package:oouchi_stock/domain/usecases/auto_add_buy_list.dart';
import 'package:oouchi_stock/domain/services/auto_buy_list_service.dart';
import 'package:oouchi_stock/domain/services/purchase_decision_service.dart';
import 'package:oouchi_stock/domain/usecases/add_buy_item.dart';
import 'package:oouchi_stock/domain/entities/buy_item.dart';
import 'package:oouchi_stock/domain/repositories/buy_list_repository.dart';

// 在庫取得用のフェイクリポジトリ
class _InvRepo implements InventoryRepository {
  final List<Inventory> list;
  _InvRepo(this.list);
  @override
  Future<String> addInventory(Inventory inventory) async => 'id';
  @override
  Future<void> deleteInventory(String id) async {}
  @override
  Future<List<Inventory>> fetchAll() async => list;
  @override
  Stream<Inventory?> watchInventory(String inventoryId) async* {}
  @override
  Stream<List<Inventory>> watchByCategory(String category) async* {}
  @override
  Stream<List<Inventory>> watchHistory(String inventoryId) async* {}
  @override
  Future<void> stocktake(String id, double before, double after, double diff) async {}
  @override
  Future<void> updateInventory(Inventory inventory) async {}
  @override
  Future<void> updateQuantity(String id, double amount, String type) async {}
  @override
  Stream<List<Inventory>> watchNeedsBuy(double threshold) async* {}
}

// 価格取得用のフェイクリポジトリ
class _PriceRepo implements PriceRepository {
  final PriceInfo price;
  _PriceRepo(this.price);
  @override
  Future<String> addPriceInfo(PriceInfo info) async => 'pid';
  @override
  Future<void> deletePriceInfo(String id) async {}
  @override
  Stream<List<PriceInfo>> watchByCategory(String category) async* {}
  @override
  Stream<List<PriceInfo>> watchByType(String category, String itemType) async* {
    yield [price];
  }
}

// 買い物リスト保存用フェイク
class _BuyRepo implements BuyListRepository {
  final List<BuyItem> items = [];
  @override
  Future<void> addItem(BuyItem item) async => items.add(item);
  @override
  Future<void> removeItem(BuyItem item) async {}
  @override
  Stream<List<BuyItem>> watchItems() async* {}
}

// AutoBuyListService の呼び出しを記録するフェイク
class _AutoService extends AutoBuyListService {
  final List<Inventory> invs = [];
  final List<PriceInfo?> prices = [];
  _AutoService() : super(AddBuyItem(_BuyRepo()), PurchaseDecisionService(1));
  @override
  Future<void> process(Inventory inv, PriceInfo? price) async {
    invs.add(inv);
    prices.add(price);
  }
}

Inventory _inv() => Inventory(
      id: 'i1',
      itemName: 'name',
      category: 'cat',
      itemType: 'type',
      quantity: 1,
      unit: '個',
      createdAt: DateTime.now(),
    );

PriceInfo _price() => PriceInfo(
      id: 'p1',
      inventoryId: 'i1',
      checkedAt: DateTime.now(),
      category: 'cat',
      itemType: 'type',
      itemName: 'name',
      count: 1,
      unit: '個',
      volume: 1,
      totalVolume: 1,
      regularPrice: 100,
      salePrice: 80,
      shop: '',
      approvalUrl: '',
      memo: '',
      unitPrice: 80,
      expiry: DateTime.now(),
    );

void main() {
  test('起動時に在庫と価格を照合してサービスが呼ばれる', () async {
    final service = _AutoService();
    final usecase = AutoAddBuyList(_InvRepo([_inv()]), _PriceRepo(_price()), service);
    await usecase();
    expect(service.invs.length, 1);
    expect(service.prices.first?.salePrice, 80);
  });
}
