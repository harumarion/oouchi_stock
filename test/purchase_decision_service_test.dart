import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';
import 'package:oouchi_stock/domain/services/purchase_decision_service.dart';
import 'package:oouchi_stock/domain/repositories/buy_prediction_repository.dart';
import 'package:oouchi_stock/domain/entities/buy_item.dart';
import 'package:oouchi_stock/domain/usecases/add_prediction_item.dart';
import 'package:oouchi_stock/domain/services/auto_prediction_list_service.dart';

class _FakeRepo implements BuyPredictionRepository {
  final List<BuyItem> items = [];
  @override
  Stream<List<BuyItem>> watchItems() async* {
    yield items;
  }

  @override
  Future<void> addItem(BuyItem item) async {
    items.add(item);
  }

  @override
  Future<void> removeItem(BuyItem item) async {
    items.removeWhere((e) => e.key == item.key);
  }
}

void main() {
  // 購入判定サービスのテスト
  final service = PurchaseDecisionService(
    2,
    cautiousDays: 3,
    bestTimeDays: 3,
    discountPercent: 10,
  );

  Inventory invWith(double q, {double consumption = 30}) => Inventory(
        id: 'id',
        itemName: 'name',
        category: 'cat',
        itemType: 'type',
        quantity: q,
        monthlyConsumption: consumption,
        unit: '個',
        createdAt: DateTime.now(),
      );

  PriceInfo price({double sale = 100, double regular = 120}) => PriceInfo(
        id: 'p',
        inventoryId: 'id',
        checkedAt: DateTime.now(),
        category: 'cat',
        itemType: 'type',
        itemName: 'name',
        count: 1,
        unit: '個',
        volume: 1,
        totalVolume: 1,
        regularPrice: regular,
        salePrice: sale,
        shop: '',
        approvalUrl: '',
        memo: '',
        unitPrice: sale,
        expiry: DateTime.now(),
      );

  test('在庫ゼロは緊急対応', () {
    expect(service.decide(invWith(0), price()),
        PurchaseDecisionType.emergency);
  });

  test('残り日数少なら慎重対応', () {
    expect(service.decide(invWith(1, consumption: 10), price()),
        PurchaseDecisionType.cautious);
  });

  test('在庫十分でセール中はまとめ買いチャンス', () {
    expect(service.decide(invWith(3), price(sale: 80, regular: 100)),
        PurchaseDecisionType.bulkOpportunity);
  });

  test('日数少かつ十分値引きなら最も買い時', () {
    expect(
        service.decide(invWith(1, consumption: 10),
            price(sale: 80, regular: 100)),
        PurchaseDecisionType.bestTime);
  });

  // 予報リスト追加処理のテスト
  test('慎重判定で予報リストへ追加', () async {
    final repo = _FakeRepo();
    final auto = AutoPredictionListService(
        AddPredictionItem(repo), service);
    await auto.process(invWith(1), price(sale: 150, regular: 100));
    expect(repo.items.length, 1);
  });

  test('緊急判定では予報リストへ追加しない', () async {
    final repo = _FakeRepo();
    final auto = AutoPredictionListService(
        AddPredictionItem(repo), service);
    await auto.process(invWith(0), price());
    expect(repo.items.isEmpty, true);
  });
}
