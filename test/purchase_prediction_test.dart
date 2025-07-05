import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/usecases/purchase_prediction_strategy.dart';
import 'package:oouchi_stock/domain/entities/history_entry.dart';

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

  test('MonthlyConsumptionStrategy は履歴から日数を計算する', () {
    final now = DateTime(2023, 1, 1);
    const strategy = MonthlyConsumptionStrategy();
    final history = [
      HistoryEntry('used', 2, now.subtract(const Duration(days: 10))),
      HistoryEntry('used', 1, now.subtract(const Duration(days: 5))),
    ];
    final result = strategy.predict(now, history, 3);
    expect(result.difference(now).inDays, 30);
  });
}
