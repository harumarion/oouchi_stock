import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oouchi_stock/add_inventory_page.dart';

void main() {
  // 加減ボタンを押した際に数量が変化するかを確認するテスト
  testWidgets('数量の増減テスト', (WidgetTester tester) async {
    // AddInventoryPage を MaterialApp でラップして表示
    await tester.pumpWidget(const MaterialApp(home: AddInventoryPage()));

    // 初期状態では数量 1.0 が表示されているはず
    expect(find.text('1.0'), findsOneWidget);

    // プラスボタンをタップして 1.1 になるか確認
    await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
    await tester.pump();
    expect(find.text('1.1'), findsOneWidget);

    // マイナスボタンをタップして 1.0 に戻るか確認
    await tester.tap(find.widgetWithIcon(IconButton, Icons.remove));
    await tester.pump();
    expect(find.text('1.0'), findsOneWidget);
  });
}
