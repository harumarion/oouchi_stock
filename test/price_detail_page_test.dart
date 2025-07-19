import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/price_detail_page.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';
import 'package:oouchi_stock/edit_price_page.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

void main() {
  testWidgets('PriceDetailPage が詳細を表示する', (WidgetTester tester) async {
    final info = PriceInfo(
      id: '1',
      inventoryId: '1',
      checkedAt: DateTime(2023, 1, 1),
      category: '日用品',
      itemType: '洗剤',
      itemName: 'テスト商品',
      count: 1,
      unit: '個',
      volume: 1,
      totalVolume: 1,
      regularPrice: 200,
      salePrice: 150,
      shop: '店',
      approvalUrl: 'https://example.com',
      memo: 'メモ',
      unitPrice: 150,
      expiry: DateTime(2023, 1, 2),
    );
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ja'),
      home: PriceDetailPage(info: info),
    ));
    expect(find.text('テスト商品'), findsOneWidget);
    // ListTile が複数表示されていることを確認
    expect(find.byType(ListTile), findsWidgets);
    expect(find.text('日用品'), findsOneWidget);
    expect(find.textContaining('150'), findsWidgets);
    // 編集アイコンが表示されていることを確認
    final editButton = find.widgetWithIcon(IconButton, Icons.edit);
    expect(editButton, findsOneWidget);

    // 編集アイコンタップで EditPricePage が開くことを確認
    await tester.tap(editButton);
    await tester.pumpAndSettle();
    expect(find.byType(EditPricePage), findsOneWidget);

    // 編集画面から更新データを渡して戻る
    Navigator.of(tester.element(find.byType(EditPricePage))).pop(
      PriceInfo(
        id: '1',
        inventoryId: '1',
        checkedAt: DateTime(2023, 1, 1),
        category: '日用品',
        itemType: '洗剤',
        itemName: '更新後',
        count: 1,
        unit: '個',
        volume: 1,
        totalVolume: 1,
        regularPrice: 200,
        salePrice: 150,
        shop: '店',
        approvalUrl: 'https://example.com',
        memo: 'メモ',
        unitPrice: 150,
        expiry: DateTime(2023, 1, 2),
      ),
    );
    await tester.pumpAndSettle();
    // 更新後の情報が画面に反映されることを確認
    expect(find.text('更新後'), findsOneWidget);
  });
}
