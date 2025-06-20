import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/widgets/ad_banner.dart';

void main() {
  testWidgets('AdBanner 初期表示', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdBanner()));
    // 端末によっては広告が読み込めないため、とりあえずウィジェットが存在するか確認
    expect(find.byType(AdBanner), findsOneWidget);
    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    // バナーの高さがナビゲーションバーと同じか確認
    expect(sizedBox.height, kBottomNavigationBarHeight);
  });
}
