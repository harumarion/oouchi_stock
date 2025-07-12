import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/edit_price_page.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';

void main() {
  testWidgets('EditPricePage が表示される', (WidgetTester tester) async {
    final info = PriceInfo(
      id: '1',
      inventoryId: '1',
      checkedAt: DateTime.now(),
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
      approvalUrl: '',
      memo: '',
      unitPrice: 150,
      expiry: DateTime.now(),
    );
    await tester.pumpWidget(MaterialApp(home: EditPricePage(info: info)));
    await tester.pump();
    expect(find.byType(Form), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
  });
}
