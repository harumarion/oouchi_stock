// 基本的な Flutter ウィジェットテストです。
//
// WidgetTester を利用すると、タップやスクロールなどの操作を模擬できます。
// ウィジェットツリーから子ウィジェットを検索したり、テキストの有無を確認すること
// で、ウィジェットの状態を検証できます。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oouchi_stock/main.dart';
import 'package:oouchi_stock/presentation/viewmodels/main_viewmodel.dart';
import 'package:oouchi_stock/add_category_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';
import 'package:oouchi_stock/theme.dart';
import 'package:oouchi_stock/widgets/splash_screen.dart';
import 'firebase_test_utils.dart';

/// テスト用のダミー MainViewModel。通信や初期化処理を行わない。
class _DummyMainViewModel extends MainViewModel {
  @override
  void startConnectivityWatch() {
    // 接続監視を無効化
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // アプリを起動した際、タイトルが表示されるかどうかを確認
  testWidgets('アプリが起動する', (WidgetTester tester) async {
    // Firebase の初期化をモック
    await setupFirebaseCoreMocks();
    final vm = _DummyMainViewModel()..locale = const Locale('ja');
    final categories = [
      Category(id: 1, name: '日用品', createdAt: DateTime.now())
    ];
    // MyApp 起動。画面タイトルが表示されることを確認
    await tester.pumpWidget(MyApp(initialCategories: categories, viewModel: vm));
    expect(find.text('買い物予報'), findsOneWidget);
  });

  // カテゴリ追加画面で名前を空のまま保存した場合にバリデーションエラーが出ることを確認
  testWidgets('カテゴリ名未入力で保存するとバリデーションエラーが表示される',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddCategoryPage()));
    await tester.tap(find.text('保存'));
    await tester.pump();
    expect(find.text('必須項目です'), findsOneWidget);
  });

  test('AppTheme のプライマリカラーが設定されている', () {
    final theme = AppTheme.lightTheme;
    expect(theme.colorScheme.primary, AppTheme.primaryColor);
  });

  // スプラッシュ画面でアイコン画像が表示されるかを確認
  testWidgets('スプラッシュ画面にアイコンが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    final image = tester.widget<Image>(find.byType(Image));
    // 画像アセットのパスが正しいか検証
    expect((image.image as AssetImage).assetName, 'web/icons/Icon-512.png');
  });
}
