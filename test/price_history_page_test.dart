import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/price_history_page.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';
import 'package:oouchi_stock/domain/repositories/price_repository.dart';
import 'package:oouchi_stock/domain/usecases/delete_price_info.dart';
import 'package:oouchi_stock/domain/usecases/watch_price_by_type.dart';

void main() {
  testWidgets('PriceHistoryPage が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PriceHistoryPage(
        category: '日用品',
        itemType: '洗剤',
        itemName: 'テスト商品',
      ),
    ));
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('行の文字サイズが18', (WidgetTester tester) async {
    final repo = _FakeRepository();
    await tester.pumpWidget(MaterialApp(
      home: PriceHistoryPage(
        category: '日用品',
        itemType: '洗剤',
        watch: WatchPriceByType(repo),
        deleter: DeletePriceInfo(repo),
      ),
    ));
    await tester.pump();
    final text = tester.widget<Text>(find.text('テスト商品'));
    expect(text.style?.fontSize, 18);
  });
}

class _FakeRepository implements PriceRepository {
  @override
  Future<String> addPriceInfo(PriceInfo info) async => '';

  @override
  Stream<List<PriceInfo>> watchByCategory(String category) => const Stream.empty();

  @override
  Stream<List<PriceInfo>> watchByType(String category, String itemType) =>
      Stream.value([
        PriceInfo(
          id: '1',
          inventoryId: '1',
          checkedAt: DateTime(2023, 1, 1),
          category: category,
          itemType: itemType,
          itemName: 'テスト商品',
          count: 1,
          unit: '個',
          volume: 1,
          totalVolume: 1,
          regularPrice: 200,
          salePrice: 150,
          shop: '店',
          approvalUrl: '',
          memo: '',
          unitPrice: 150,
          expiry: DateTime(2023, 1, 2),
        )
      ]);

  @override
  Future<void> deletePriceInfo(String id) async {}
}
