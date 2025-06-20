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
    // タブは廃止されたため存在しない
    expect(find.byType(TabBar), findsNothing);
  });

  testWidgets('設定メニューボタンが表示される', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final categories = [Category(id: 1, name: 'X', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(home: BuyListPage(categories: categories)));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('削除時に数量入力ダイアログが表示される', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'buy_list_items': ['|テスト|inv1']
    });
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(home: BuyListPage(categories: categories)));
    await tester.pumpAndSettle();
    expect(find.text('テスト'), findsOneWidget);

    await tester.drag(find.text('テスト'), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
