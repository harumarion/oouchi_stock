import '../entities/buy_item.dart';
import '../repositories/buy_prediction_repository.dart';

/// 買い物予報リストからアイテムを削除するユースケース
class RemovePredictionItem {
  /// データ保存先リポジトリ
  final BuyPredictionRepository repository;

  RemovePredictionItem(this.repository);

  /// アイテムを削除する
  Future<void> call(BuyItem item) => repository.removeItem(item);
}
