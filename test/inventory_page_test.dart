import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/inventory_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('InventoryPage 検索バー表示', (WidgetTester tester) async {
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(home: InventoryPage(categories: categories)));
    // タブが描画されるまで待機
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsWidgets);
    // SegmentedButton が表示されているか確認
    expect(find.byType(SegmentedButton<int>), findsOneWidget);
    // 右下の FAB が表示されているか確認
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('カテゴリがない場合はメッセージと追加ボタンを表示', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: InventoryPage()));
    await tester.pumpAndSettle();
    expect(find.text('カテゴリが登録されていません'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('タイトルが左寄せになっている', (WidgetTester tester) async {
    final categories = [Category(id: 1, name: 'A', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(home: InventoryPage(categories: categories)));
    await tester.pumpAndSettle();
    final appBar = tester.widget<AppBar>(find.byType(AppBar).first);
    expect(appBar.centerTitle, isFalse);
  });

  testWidgets('カテゴリ変更で一覧も更新される', (WidgetTester tester) async {
    final categories = [
      Category(id: 1, name: 'A', createdAt: DateTime.now()),
      Category(id: 2, name: 'B', createdAt: DateTime.now()),
    ];
    await tester.pumpWidget(MaterialApp(home: InventoryPage(categories: categories)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    final list = tester.widget<InventoryList>(find.byType(InventoryList));
    expect(list.category, 'B');
  });
}
