// 基本的な Flutter ウィジェットテストです。
//
// WidgetTester を利用すると、タップやスクロールなどの操作を模擬できます。
// ウィジェットツリーから子ウィジェットを検索したり、テキストの有無を確認すること
// で、ウィジェットの状態を検証できます。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oouchi_stock/main.dart';
import 'package:oouchi_stock/add_category_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';
import 'package:oouchi_stock/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // アプリを起動した際、タイトルが表示されるかどうかを確認
  testWidgets('アプリが起動する', (WidgetTester tester) async {
    final categories = [
      Category(id: 1, name: '日用品', createdAt: DateTime.now())
    ];
    await tester.pumpWidget(MyApp(initialCategories: categories));
    expect(find.text('買い物予報'), findsOneWidget);
  });

  // カテゴリ追加画面で名前を空のまま保存した場合にバリデーションエラーが出ることを確認
  testWidgets('カテゴリ名未入力で保存するとバリデーションエラーが表示される',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddCategoryPage()));
    await tester.tap(find.text('保存'));
    await tester.pump();
    expect(find.text('必須項目です'), findsOneWidget);
  });

  test('AppTheme のプライマリカラーが設定されている', () {
    final theme = AppTheme.lightTheme;
    expect(theme.colorScheme.primary, AppTheme.primaryColor);
  });
}
