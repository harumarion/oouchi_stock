import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/inventory_detail_page.dart';

void main() {
  // ダミー予測戦略の戻り値を確認するテスト
  test('DummyPredictionStrategy は常に 7 日後を返す', () {
    // 現在時刻を固定
    final now = DateTime(2023, 1, 1);
    // ダミー戦略インスタンス
    const strategy = DummyPredictionStrategy();
    // 予測結果を取得
    final result = strategy.predict(now, const [], 0);
    // 期待される日時
    final expected = now.add(const Duration(days: 7));
    // 結果が期待通りか確認
    expect(result, expected);
  });
}
