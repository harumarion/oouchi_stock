import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/home_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';
import 'package:oouchi_stock/widgets/category_segmented_button.dart';

void main() {
  // ホーム画面を表示したときにカテゴリ切り替えボタンが存在することを確認するテスト
  testWidgets('HomePage でカテゴリボタンが表示される',
      (WidgetTester tester) async {
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(home: HomePage(categories: categories)));
    await tester.pump();
    expect(find.byType(CategorySegmentedButton), findsOneWidget);
    expect(find.byType(SearchAnchor), findsOneWidget);
  });

  testWidgets('カテゴリがない場合はメッセージと追加ボタンを表示', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();
    expect(find.text('カテゴリが登録されていません'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
