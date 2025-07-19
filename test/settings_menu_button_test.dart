import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/widgets/settings_menu_button.dart';
import 'package:oouchi_stock/domain/entities/category.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

void main() {
  testWidgets('設定メニューにセール情報管理項目がない', (WidgetTester tester) async {
    final categories = [Category(id: 1, name: 'A', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ja'),
      home: Scaffold(
        body: SettingsMenuButton(
          categories: categories,
          onCategoriesChanged: (_) {},
          onLocaleChanged: (_) {},
          onConditionChanged: () {},
        ),
      ),
    ));
    // メニューボタンをタップしてポップアップを表示
    await tester.tap(find.byType(SettingsMenuButton));
    await tester.pumpAndSettle();
    // PopupMenuItem は1件のみであることを確認
    expect(find.byType(PopupMenuItem), findsOneWidget);
    // セール情報管理の文言が存在しないことを確認
    expect(find.text('セール情報管理'), findsNothing);
  });
}
