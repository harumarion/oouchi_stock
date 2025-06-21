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
    // 買い物リスト追加ボタンが存在するか確認
    expect(find.byIcon(Icons.playlist_add), findsWidgets);
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
}
