import '../repositories/ad_config_repository.dart';

/// 広告表示設定を読み込むユースケース
class LoadAdEnabled {
  final AdConfigRepository repository;
  LoadAdEnabled(this.repository);

  /// true なら広告を表示する
  Future<bool> call() => repository.loadEnabled();
}
