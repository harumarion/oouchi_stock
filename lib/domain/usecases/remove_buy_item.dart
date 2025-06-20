import '../entities/buy_item.dart';
import '../repositories/buy_list_repository.dart';

/// 買い物リストからアイテムを削除するユースケース
class RemoveBuyItem {
  /// データ保存先リポジトリ
  final BuyListRepository repository;

  RemoveBuyItem(this.repository);

  /// アイテムを削除する
  Future<void> call(BuyItem item) => repository.removeItem(item);
}
