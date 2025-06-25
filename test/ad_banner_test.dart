import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/widgets/ad_banner.dart';

void main() {
  // AdBanner ウィジェットが正常に構築されるか確認するテスト
  testWidgets('AdBanner 初期表示', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdBanner()));
    // 端末によって広告が表示されない場合もあるためウィジェットの存在のみ確認
    expect(find.byType(AdBanner), findsOneWidget);
    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    // モバイル端末では広告の高さ、その他の環境では 0 を想定
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      expect(sizedBox.height, kBottomNavigationBarHeight);
    } else {
      expect(sizedBox.height, 0);
    }
  });
}
