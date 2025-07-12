import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';
import 'package:oouchi_stock/domain/entities/buy_item.dart';
import 'package:oouchi_stock/domain/repositories/buy_prediction_repository.dart';
import 'package:oouchi_stock/domain/usecases/add_prediction_item.dart';
import 'package:oouchi_stock/domain/usecases/auto_add_prediction_item.dart';
import 'package:oouchi_stock/domain/usecases/purchase_decision.dart';

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

Inventory inv(double q, {double consumption = 30}) => Inventory(
      id: 'i',
      itemName: 'name',
      category: 'cat',
      itemType: 'type',
      quantity: q,
      volume: 1,
      totalVolume: q,
      monthlyConsumption: consumption,
      unit: '個',
      createdAt: DateTime.now(),
    );

PriceInfo price(double sale, double regular) => PriceInfo(
      id: 'p',
      inventoryId: 'i',
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

void main() {
  test('慎重またはまとめ買い判定で自動追加される', () async {
    final repo = _FakeRepo();
    final uc = AutoAddPredictionItem(
        AddPredictionItem(repo),
        PurchaseDecision(2,
            cautiousDays: 3, bestTimeDays: 3, discountPercent: 10));
    await uc(inv(1, consumption: 10), price(150, 100));
    expect(repo.items.length, 1);
    await uc(inv(3), price(80, 100));
    expect(repo.items.length, 2);
  });

  test('緊急や買い時判定では追加されない', () async {
    final repo = _FakeRepo();
    final uc = AutoAddPredictionItem(
        AddPredictionItem(repo),
        PurchaseDecision(2,
            cautiousDays: 3, bestTimeDays: 3, discountPercent: 10));
    await uc(inv(0), price(100, 120));
    await uc(inv(1, consumption: 10), price(80, 100));
    expect(repo.items.isEmpty, true);
  });
}
