import '../repositories/ad_config_repository.dart';

/// 広告表示設定を保存するユースケース
class SaveAdEnabled {
  final AdConfigRepository repository;
  SaveAdEnabled(this.repository);

  /// [enabled] が true のとき広告を表示する設定で保存する
  Future<void> call(bool enabled) => repository.saveEnabled(enabled);
}
