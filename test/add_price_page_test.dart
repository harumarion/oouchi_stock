import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/add_price_page.dart';

void main() {
  testWidgets('在庫がない場合は商品追加ボタンを表示', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddPricePage()));
    await tester.pump();
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('商品を追加'), findsOneWidget);
  });
}
