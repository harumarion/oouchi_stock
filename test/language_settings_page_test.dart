import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/language_settings_page.dart';

void main() {
  testWidgets('LanguageSettingsPage 表示', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LanguageSettingsPage(
        current: const Locale('ja'),
        onSelected: (_) {},
      ),
    ));
    expect(find.text('日本語'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });
}
