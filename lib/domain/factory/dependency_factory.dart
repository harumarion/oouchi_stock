import '../entities/buy_item.dart';
import '../entities/purchase_decision_settings.dart' as purchase_settings;
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
import 'entity_factory.dart';
import 'repository_factory.dart';
import 'usecase_factory.dart';

/// アプリ全体で利用するファクトリ群をまとめるディレクトリのハブ
/// 既存コード互換のための委譲メソッドも提供する
class DependencyFactory {
  DependencyFactory._internal()
      : repositories = RepositoryFactory.instance,
        usecases = UsecaseFactory.instance,
        entities = EntityFactory.instance;

  /// instance: シングルトンインスタンス
  static final DependencyFactory instance = DependencyFactory._internal();

  /// repositories: リポジトリ生成ファクトリ
  final RepositoryFactory repositories;

  /// usecases: ユースケース生成ファクトリ
  final UsecaseFactory usecases;

  /// entities: エンティティ生成ファクトリ
  final EntityFactory entities;

  /// 在庫関連リポジトリを取得
  InventoryRepository get inventoryRepository =>
      repositories.inventoryRepository;

  /// 価格関連リポジトリを取得
  PriceRepository get priceRepository => repositories.priceRepository;

  /// 買い物リスト関連リポジトリを取得
  BuyListRepository get buyListRepository =>
      repositories.buyListRepository;

  /// 買い物予報関連リポジトリを取得
  BuyPredictionRepository get buyPredictionRepository =>
      repositories.buyPredictionRepository;

  /// カテゴリ関連リポジトリを取得
  CategoryRepository get categoryRepository =>
      repositories.categoryRepository;

  /// アイテム種別関連リポジトリを取得
  ItemTypeRepository get itemTypeRepository =>
      repositories.itemTypeRepository;

  /// 広告設定リポジトリを取得
  AdConfigRepository get adConfigRepository =>
      repositories.adConfigRepository;

  /// 在庫追加ユースケースを生成
  AddInventory createAddInventory({InventoryRepository? repository}) =>
      usecases.createAddInventory(repository: repository);

  /// 在庫更新ユースケースを生成
  UpdateInventory createUpdateInventory({InventoryRepository? repository}) =>
      usecases.createUpdateInventory(repository: repository);

  /// 在庫削除ユースケースを生成
  DeleteInventoryWithRelations createDeleteInventoryWithRelations({
    InventoryRepository? inventory,
    PriceRepository? price,
    BuyListRepository? buyList,
    BuyPredictionRepository? prediction,
  }) =>
      usecases.createDeleteInventoryWithRelations(
        inventory: inventory,
        price: price,
        buyList: buyList,
        prediction: prediction,
      );

  /// 在庫一覧監視ユースケースを生成
  WatchInventories createWatchInventories({InventoryRepository? repository}) =>
      usecases.createWatchInventories(repository: repository);

  /// 在庫単体監視ユースケースを生成
  WatchInventory createWatchInventory({InventoryRepository? repository}) =>
      usecases.createWatchInventory(repository: repository);

  /// 在庫全件取得ユースケースを生成
  FetchAllInventory createFetchAllInventory({
    InventoryRepository? repository,
  }) =>
      usecases.createFetchAllInventory(repository: repository);

  /// 在庫数量更新ユースケースを生成
  UpdateQuantity createUpdateQuantity({InventoryRepository? repository}) =>
      usecases.createUpdateQuantity(repository: repository);

  /// 棚卸しユースケースを生成
  Stocktake createStocktake({InventoryRepository? repository}) =>
      usecases.createStocktake(repository: repository);

  /// 残り日数計算ユースケースを生成
  CalculateDaysLeft createCalculateDaysLeft({
    InventoryRepository? repository,
  }) =>
      usecases.createCalculateDaysLeft(repository: repository);

  /// 価格追加ユースケースを生成
  AddPriceInfo createAddPriceInfo({PriceRepository? repository}) =>
      usecases.createAddPriceInfo(repository: repository);

  /// 価格更新ユースケースを生成
  UpdatePriceInfo createUpdatePriceInfo({PriceRepository? repository}) =>
      usecases.createUpdatePriceInfo(repository: repository);

  /// 価格削除ユースケースを生成
  DeletePriceInfo createDeletePriceInfo({PriceRepository? repository}) =>
      usecases.createDeletePriceInfo(repository: repository);

  /// カテゴリ別価格監視ユースケースを生成
  WatchPriceByCategory createWatchPriceByCategory({
    PriceRepository? repository,
  }) =>
      usecases.createWatchPriceByCategory(repository: repository);

  /// 種別別価格監視ユースケースを生成
  WatchPriceByType createWatchPriceByType({PriceRepository? repository}) =>
      usecases.createWatchPriceByType(repository: repository);

  /// 買い物リスト追加ユースケースを生成
  AddBuyItem createAddBuyItem({BuyListRepository? repository}) =>
      usecases.createAddBuyItem(repository: repository);

  /// 買い物リスト削除ユースケースを生成
  RemoveBuyItem createRemoveBuyItem({BuyListRepository? repository}) =>
      usecases.createRemoveBuyItem(repository: repository);

  /// 買い物リスト監視ユースケースを生成
  WatchBuyItems createWatchBuyItems({BuyListRepository? repository}) =>
      usecases.createWatchBuyItems(repository: repository);

  /// 自動買い物追加ユースケースを生成
  AutoAddBuyItem createAutoAddBuyItem(
    PurchaseDecision decision, {
    AddBuyItem? addUsecase,
  }) =>
      usecases.createAutoAddBuyItem(decision, addUsecase: addUsecase);

  /// 買い物予報追加ユースケースを生成
  AddPredictionItem createAddPredictionItem({
    BuyPredictionRepository? repository,
  }) =>
      usecases.createAddPredictionItem(repository: repository);

  /// 買い物予報削除ユースケースを生成
  RemovePredictionItem createRemovePredictionItem({
    BuyPredictionRepository? repository,
  }) =>
      usecases.createRemovePredictionItem(repository: repository);

  /// 買い物予報監視ユースケースを生成
  WatchPredictionItems createWatchPredictionItems({
    BuyPredictionRepository? repository,
  }) =>
      usecases.createWatchPredictionItems(repository: repository);

  /// 自動予報追加ユースケースを生成
  AutoAddPredictionItem createAutoAddPredictionItem(
    PurchaseDecision decision, {
    AddPredictionItem? addUsecase,
  }) =>
      usecases.createAutoAddPredictionItem(
        decision,
        addUsecase: addUsecase,
      );

  /// カテゴリ追加ユースケースを生成
  AddCategory createAddCategory({CategoryRepository? repository}) =>
      usecases.createAddCategory(repository: repository);

  /// カテゴリ更新ユースケースを生成
  UpdateCategory createUpdateCategory({CategoryRepository? repository}) =>
      usecases.createUpdateCategory(repository: repository);

  /// アイテム種別追加ユースケースを生成
  AddItemType createAddItemType({ItemTypeRepository? repository}) =>
      usecases.createAddItemType(repository: repository);

  /// アイテム種別更新ユースケースを生成
  UpdateItemType createUpdateItemType({ItemTypeRepository? repository}) =>
      usecases.createUpdateItemType(repository: repository);

  /// 広告有効状態読み込みユースケースを生成
  LoadAdEnabled createLoadAdEnabled({AdConfigRepository? repository}) =>
      usecases.createLoadAdEnabled(repository: repository);

  /// 広告有効状態保存ユースケースを生成
  SaveAdEnabled createSaveAdEnabled({AdConfigRepository? repository}) =>
      usecases.createSaveAdEnabled(repository: repository);

  /// 買い物リストアイテムエンティティを生成
  BuyItem createBuyItem(
    String name,
    String category,
    String? inventoryId,
    BuyItemReason reason,
  ) =>
      entities.createBuyItem(name, category, inventoryId, reason);

  /// 購入判定ユースケースを生成
  PurchaseDecision createPurchaseDecision({
    required double threshold,
    required purchase_settings.PurchaseDecisionSettings settings,
  }) =>
      entities.createPurchaseDecision(
        threshold: threshold,
        settings: settings,
      );

  /// 購入判定設定を読み込む
  Future<purchase_settings.PurchaseDecisionSettings>
      loadPurchaseDecisionSettings() =>
          entities.loadPurchaseDecisionSettings();

  /// 購入判定設定を保存する
  Future<void> savePurchaseDecisionSettings(
    purchase_settings.PurchaseDecisionSettings settings,
  ) =>
      entities.savePurchaseDecisionSettings(settings);
}
