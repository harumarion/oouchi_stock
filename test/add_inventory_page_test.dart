import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oouchi_stock/add_inventory_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  // 加減ボタンを押した際に数量が変化するかを確認するテスト
  testWidgets('数量の増減テスト', (WidgetTester tester) async {
    // AddInventoryPage を MaterialApp でラップして表示
    await tester.pumpWidget(
      MaterialApp(
        home: AddInventoryPage(
          categories: [Category(id: 1, name: '日用品', createdAt: DateTime.now())],
        ),
      ),
    );

    // 初期状態では数量 1 が表示されているはず
    expect(find.text('1'), findsOneWidget);

    // プラスボタンをタップして 2 になるか確認
    await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    // マイナスボタンをタップして 1 に戻るか確認
    await tester.tap(find.widgetWithIcon(IconButton, Icons.remove));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('設定メニューが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddInventoryPage(
          categories: [Category(id: 1, name: '日用品', createdAt: DateTime.now())],
        ),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  // Navigator.canPop が false の場合でも画面が消えないことを確認するテスト
  testWidgets('保存後も画面が残る', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddInventoryPage(
          categories: [Category(id: 1, name: '日用品', createdAt: DateTime.now())],
        ),
      ),
    );

    // 商品名を入力してフォームを有効にする
    await tester.enterText(find.byType(TextFormField).first, 'シャンプー');
    // 保存ボタンをタップ
    await tester.tap(find.widgetWithIcon(ElevatedButton, Icons.save));
    await tester.pumpAndSettle();

    // Navigator.pop が呼ばれないため画面は残っているはず
    expect(find.byType(AddInventoryPage), findsOneWidget);
  });
}
