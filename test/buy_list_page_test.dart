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
    // 手動タブが表示されているか確認
    expect(find.text('手動'), findsOneWidget);
  });

  testWidgets('カテゴリの並び順が保存順に反映される', (WidgetTester tester) async {
    // SharedPreferences に並び順を保存
    SharedPreferences.setMockInitialValues({
      'category_order': ['2', '1']
    });
    final categories = [
      Category(id: 1, name: 'A', createdAt: DateTime.now()),
      Category(id: 2, name: 'B', createdAt: DateTime.now()),
    ];
    await tester.pumpWidget(MaterialApp(home: BuyListPage(categories: categories)));
    // タブが描画されるまで待機
    await tester.pumpAndSettle();
    final tabs = tester.widgetList<Tab>(find.byType(Tab)).toList();
    final labels = tabs.map((t) => t.text).toList();
    expect(labels, ['手動', 'B', 'A']);
  });
}
