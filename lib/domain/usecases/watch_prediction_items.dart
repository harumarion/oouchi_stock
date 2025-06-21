import '../entities/buy_item.dart';
import '../repositories/buy_prediction_repository.dart';

/// 買い物予報リストの変更を監視するユースケース
class WatchPredictionItems {
  /// データ取得元リポジトリ
  final BuyPredictionRepository repository;

  WatchPredictionItems(this.repository);

  /// 変更をストリームで取得する
  Stream<List<BuyItem>> call() => repository.watchItems();
}
