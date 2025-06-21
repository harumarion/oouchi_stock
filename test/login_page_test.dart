import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/login_page.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

void main() {
  // ローカライズ未読み込みでもクラッシュしないか確認
  testWidgets('LoginPage 表示テスト', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ja'),
      home: LoginPage(onLoggedIn: () {}),
    ));
    expect(find.text('匿名で続行'), findsOneWidget);
    expect(find.text('Googleでログイン'), findsOneWidget);
  });
}
