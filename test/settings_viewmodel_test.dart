import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oouchi_stock/presentation/viewmodels/settings_viewmodel.dart';
import 'firebase_test_utils.dart';

void main() {
  test('バックアップがない場合 restore() は null を返す', () async {
    await setupFirebaseCoreMocks();
    SharedPreferences.setMockInitialValues({});
    final vm = SettingsViewModel();
    final result = await vm.restore();
    expect(result, isNull);
  });
}
