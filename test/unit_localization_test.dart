import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/util/unit_localization.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'package:oouchi_stock/util/constants.dart';

void main() {
  // 新しく追加した単位がローカライズされるかを確認
  testWidgets('新規単位のローカライズ', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ja'),
        home: Builder(
          builder: (context) {
            return Column(
              children: defaultUnits
                  .map((u) => Text(localizeUnit(context, u)))
                  .toList(),
            );
          },
        ),
      ),
    );

    await tester.pump();
    expect(find.text('ミリリットル'), findsOneWidget);
    expect(find.text('グラム'), findsOneWidget);
    expect(find.text('キログラム'), findsOneWidget);
  });
}
