/// 広告表示設定を扱うリポジトリ
abstract class AdConfigRepository {
  /// 設定を読み込む
  Future<bool> loadEnabled();

  /// 設定を保存する
  Future<void> saveEnabled(bool enabled);
}
