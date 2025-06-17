import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/add_price_page.dart';

void main() {
  testWidgets('AddPricePage 初期表示', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddPricePage()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
