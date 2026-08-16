import '../repositories/ad_config_repository.dart';
import '../repositories/buy_list_repository.dart';
import '../repositories/buy_prediction_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/item_type_repository.dart';
import '../repositories/price_repository.dart';
import '../usecases/add_buy_item.dart';
import '../usecases/add_category.dart';
import '../usecases/add_inventory.dart';
import '../usecases/add_item_type.dart';
import '../usecases/add_prediction_item.dart';
import '../usecases/add_price_info.dart';
import '../usecases/auto_add_buy_item.dart';
import '../usecases/auto_add_prediction_item.dart';
import '../usecases/calculate_days_left.dart';
import '../usecases/delete_inventory_with_relations.dart';
import '../usecases/delete_price_info.dart';
import '../usecases/fetch_all_inventory.dart';
import '../usecases/load_ad_enabled.dart';
import '../usecases/purchase_decision.dart';
import '../usecases/remove_buy_item.dart';
import '../usecases/remove_prediction_item.dart';
import '../usecases/save_ad_enabled.dart';
import '../usecases/stocktake.dart';
import '../usecases/update_category.dart';
import '../usecases/update_inventory.dart';
import '../usecases/update_item_type.dart';
import '../usecases/update_price_info.dart';
import '../usecases/update_quantity.dart';
import '../usecases/watch_buy_items.dart';
import '../usecases/watch_inventories.dart';
import '../usecases/watch_inventory.dart';
import '../usecases/watch_prediction_items.dart';
import '../usecases/watch_price_by_category.dart';
import '../usecases/watch_price_by_type.dart';
import 'repository_factory.dart';

/// ユースケース生成を担当するファクトリクラス（画面操作単位で利用）
class UsecaseFactory {
  UsecaseFactory._internal(this._repositories);

  /// instance: シングルトンインスタンス
  static final UsecaseFactory instance =
      UsecaseFactory._internal(RepositoryFactory.instance);

  /// _repositories: リポジトリ生成ファクトリへの参照
  final RepositoryFactory _repositories;

  /// 在庫追加ユースケースを生成（在庫登録画面で使用）
  AddInventory createAddInventory({InventoryRepository? repository}) =>
      AddInventory(repository ?? _repositories.inventoryRepository);

  /// 在庫更新ユースケースを生成（在庫詳細画面で使用）
  UpdateInventory createUpdateInventory({InventoryRepository? repository}) =>
      UpdateInventory(repository ?? _repositories.inventoryRepository);

  /// 在庫削除ユースケースを生成（在庫詳細画面で使用）
  DeleteInventoryWithRelations createDeleteInventoryWithRelations({
    InventoryRepository? inventory,
    PriceRepository? price,
    BuyListRepository? buyList,
    BuyPredictionRepository? prediction,
  }) =>
      DeleteInventoryWithRelations(
        inventory ?? _repositories.inventoryRepository,
        price ?? _repositories.priceRepository,
        buyList ?? _repositories.buyListRepository,
        prediction ?? _repositories.buyPredictionRepository,
      );

  /// 在庫一覧監視ユースケースを生成（在庫一覧画面で使用）
  WatchInventories createWatchInventories({
    InventoryRepository? repository,
  }) =>
      WatchInventories(repository ?? _repositories.inventoryRepository);

  /// 在庫単体監視ユースケースを生成（ホーム画面で使用）
  WatchInventory createWatchInventory({InventoryRepository? repository}) =>
      WatchInventory(repository ?? _repositories.inventoryRepository);

  /// 在庫全件取得ユースケースを生成（バックアップ処理で使用）
  FetchAllInventory createFetchAllInventory({
    InventoryRepository? repository,
  }) =>
      FetchAllInventory(repository ?? _repositories.inventoryRepository);

  /// 在庫数量更新ユースケースを生成（棚卸し操作で使用）
  UpdateQuantity createUpdateQuantity({InventoryRepository? repository}) =>
      UpdateQuantity(repository ?? _repositories.inventoryRepository);

  /// 棚卸しユースケースを生成（棚卸し画面で使用）
  Stocktake createStocktake({InventoryRepository? repository}) =>
      Stocktake(repository ?? _repositories.inventoryRepository);

  /// 残り日数計算ユースケースを生成（ホーム画面で使用）
  CalculateDaysLeft createCalculateDaysLeft({
    InventoryRepository? repository,
  }) =>
      CalculateDaysLeft(repository ?? _repositories.inventoryRepository);

  /// 価格追加ユースケースを生成（価格登録画面で使用）
  AddPriceInfo createAddPriceInfo({PriceRepository? repository}) =>
      AddPriceInfo(repository ?? _repositories.priceRepository);

  /// 価格更新ユースケースを生成（価格編集画面で使用）
  UpdatePriceInfo createUpdatePriceInfo({PriceRepository? repository}) =>
      UpdatePriceInfo(repository ?? _repositories.priceRepository);

  /// 価格削除ユースケースを生成（価格履歴画面で使用）
  DeletePriceInfo createDeletePriceInfo({PriceRepository? repository}) =>
      DeletePriceInfo(repository ?? _repositories.priceRepository);

  /// カテゴリ別価格監視ユースケースを生成（価格統計画面で使用）
  WatchPriceByCategory createWatchPriceByCategory({
    PriceRepository? repository,
  }) =>
      WatchPriceByCategory(repository ?? _repositories.priceRepository);

  /// 種別別価格監視ユースケースを生成（価格統計画面で使用）
  WatchPriceByType createWatchPriceByType({PriceRepository? repository}) =>
      WatchPriceByType(repository ?? _repositories.priceRepository);

  /// 買い物リスト追加ユースケースを生成（ホーム画面の追加ボタンで使用）
  AddBuyItem createAddBuyItem({BuyListRepository? repository}) =>
      AddBuyItem(repository ?? _repositories.buyListRepository);

  /// 買い物リスト削除ユースケースを生成（買い物リスト画面で使用）
  RemoveBuyItem createRemoveBuyItem({BuyListRepository? repository}) =>
      RemoveBuyItem(repository ?? _repositories.buyListRepository);

  /// 買い物リスト監視ユースケースを生成（買い物リスト画面で使用）
  WatchBuyItems createWatchBuyItems({BuyListRepository? repository}) =>
      WatchBuyItems(repository ?? _repositories.buyListRepository);

  /// 自動買い物追加ユースケースを生成（ホーム画面の自動提案で使用）
  AutoAddBuyItem createAutoAddBuyItem(
    PurchaseDecision decision, {
    AddBuyItem? addUsecase,
  }) =>
      AutoAddBuyItem(addUsecase ?? createAddBuyItem(), decision);

  /// 買い物予報追加ユースケースを生成（ホーム画面の予報カードで使用）
  AddPredictionItem createAddPredictionItem({
    BuyPredictionRepository? repository,
  }) =>
      AddPredictionItem(repository ?? _repositories.buyPredictionRepository);

  /// 買い物予報削除ユースケースを生成（ホーム画面の予報カードで使用）
  RemovePredictionItem createRemovePredictionItem({
    BuyPredictionRepository? repository,
  }) =>
      RemovePredictionItem(repository ?? _repositories.buyPredictionRepository);

  /// 買い物予報監視ユースケースを生成（ホーム画面の予報リストで使用）
  WatchPredictionItems createWatchPredictionItems({
    BuyPredictionRepository? repository,
  }) =>
      WatchPredictionItems(repository ?? _repositories.buyPredictionRepository);

  /// 自動予報追加ユースケースを生成（ホーム画面の自動提案で使用）
  AutoAddPredictionItem createAutoAddPredictionItem(
    PurchaseDecision decision, {
    AddPredictionItem? addUsecase,
  }) =>
      AutoAddPredictionItem(
        addUsecase ?? createAddPredictionItem(),
        decision,
      );

  /// カテゴリ追加ユースケースを生成（カテゴリ追加画面で使用）
  AddCategory createAddCategory({CategoryRepository? repository}) =>
      AddCategory(repository ?? _repositories.categoryRepository);

  /// カテゴリ更新ユースケースを生成（カテゴリ編集画面で使用）
  UpdateCategory createUpdateCategory({CategoryRepository? repository}) =>
      UpdateCategory(repository ?? _repositories.categoryRepository);

  /// アイテム種別追加ユースケースを生成（アイテム種別追加画面で使用）
  AddItemType createAddItemType({ItemTypeRepository? repository}) =>
      AddItemType(repository ?? _repositories.itemTypeRepository);

  /// アイテム種別更新ユースケースを生成（アイテム種別編集画面で使用）
  UpdateItemType createUpdateItemType({ItemTypeRepository? repository}) =>
      UpdateItemType(repository ?? _repositories.itemTypeRepository);

  /// 広告有効状態読み込みユースケースを生成（設定画面で使用）
  LoadAdEnabled createLoadAdEnabled({AdConfigRepository? repository}) =>
      LoadAdEnabled(repository ?? _repositories.adConfigRepository);

  /// 広告有効状態保存ユースケースを生成（設定画面で使用）
  SaveAdEnabled createSaveAdEnabled({AdConfigRepository? repository}) =>
      SaveAdEnabled(repository ?? _repositories.adConfigRepository);
}
