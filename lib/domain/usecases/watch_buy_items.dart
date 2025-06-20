import '../entities/buy_item.dart';
import '../repositories/buy_list_repository.dart';

/// 買い物リストの変更を監視するユースケース
class WatchBuyItems {
  /// データ取得元リポジトリ
  final BuyListRepository repository;

  WatchBuyItems(this.repository);

  /// 変更をストリームで取得する
  Stream<List<BuyItem>> call() => repository.watchItems();
}
