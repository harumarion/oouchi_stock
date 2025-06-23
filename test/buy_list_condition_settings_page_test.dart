import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/buy_list_condition_settings_page.dart';
import 'package:oouchi_stock/domain/entities/buy_list_condition_settings.dart';

// 買い物予報条件設定画面のウィジェットテスト

void main() {
  testWidgets('BuyListConditionSettingsPage 表示', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BuyListConditionSettingsPage()));
    expect(find.text('買い物予報条件設定'), findsOneWidget);
  });

  testWidgets('入力値が状態として保持される', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BuyListConditionSettingsPage()));
    // しきい値に5を入力
    await tester.enterText(find.byType(TextField).at(0), '5');
    // 日数に10を入力
    await tester.enterText(find.byType(TextField).at(1), '10');
    // ラジオボタンを切り替える
    await tester.tap(find.byType(RadioListTile<BuyListConditionType>).at(1));
    await tester.pump();
    // 入力値が保持されていることを確認
    expect(find.widgetWithText(TextField, '5'), findsOneWidget);
    expect(find.widgetWithText(TextField, '10'), findsOneWidget);
  });
}
