import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/presentation/viewmodels/main_viewmodel.dart';
import 'package:oouchi_stock/util/webview_checker.dart';
import 'firebase_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('WebView が利用できない端末でも初期化は完了する', () async {
    await setupFirebaseCoreMocks();
    WebViewChecker.setMockResult(false);
    final vm = MainViewModel();
    await vm.init();
    expect(vm.initialized, isTrue);
  });
}
