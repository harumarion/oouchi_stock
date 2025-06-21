import '../entities/buy_item.dart';
import '../repositories/buy_prediction_repository.dart';

/// 買い物予報リストにアイテムを追加するユースケース
class AddPredictionItem {
  /// データ保存先リポジトリ
  final BuyPredictionRepository repository;

  AddPredictionItem(this.repository);

  /// アイテムを追加する
  Future<void> call(BuyItem item) => repository.addItem(item);
}
