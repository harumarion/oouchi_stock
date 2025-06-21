import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/price_detail_page.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';

void main() {
  testWidgets('PriceDetailPage が詳細を表示する', (WidgetTester tester) async {
    final info = PriceInfo(
      id: '1',
      inventoryId: '1',
      checkedAt: DateTime(2023, 1, 1),
      category: '日用品',
      itemType: '洗剤',
      itemName: 'テスト商品',
      count: 1,
      unit: '個',
      volume: 1,
      totalVolume: 1,
      regularPrice: 200,
      salePrice: 150,
      shop: '店',
      approvalUrl: 'https://example.com',
      memo: 'メモ',
      unitPrice: 150,
      expiry: DateTime(2023, 1, 2),
    );
    await tester.pumpWidget(MaterialApp(home: PriceDetailPage(info: info)));
    expect(find.text('テスト商品'), findsOneWidget);
    expect(find.text('日用品'), findsOneWidget);
    expect(find.textContaining('150'), findsWidgets);
  });
}
