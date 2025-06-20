import '../entities/buy_item.dart';
import '../repositories/buy_list_repository.dart';

/// 買い物リストにアイテムを追加するユースケース
class AddBuyItem {
  /// データ保存先リポジトリ
  final BuyListRepository repository;

  AddBuyItem(this.repository);

  /// アイテムを追加する
  Future<void> call(BuyItem item) => repository.addItem(item);
}
