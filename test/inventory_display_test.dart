import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'package:oouchi_stock/util/inventory_display.dart';

void main() {
  testWidgets('formatRemainingは数量→単位→総容量の順で表示', (tester) async {
    final inv = Inventory(
      id: '1',
      itemName: '水',
      category: '飲料',
      itemType: 'その他',
      quantity: 2,
      volume: 100,
      totalVolume: 200,
      unit: 'ミリリットル',
      createdAt: DateTime(2020),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ja'),
        home: Builder(
          builder: (context) {
            return Text(formatRemaining(context, inv));
          },
        ),
      ),
    );

    await tester.pump();
    expect(find.text('残り2.0(200.0ミリリットル)'), findsOneWidget);
  });
}
