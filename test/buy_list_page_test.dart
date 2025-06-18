import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/buy_list_page.dart';

void main() {
  testWidgets('BuyListPage が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BuyListPage(categories: [])));
    expect(find.byType(AppBar), findsOneWidget);
  });
}
