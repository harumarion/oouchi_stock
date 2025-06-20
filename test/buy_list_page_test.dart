import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/buy_list_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('BuyListPage 追加入力欄表示', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(home: BuyListPage(categories: categories)));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
  });
}
