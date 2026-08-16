import '../../data/repositories/ad_config_repository_impl.dart';
import '../../data/repositories/buy_list_repository_impl.dart';
import '../../data/repositories/buy_prediction_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../data/repositories/item_type_repository_impl.dart';
import '../../data/repositories/price_repository_impl.dart';
import '../repositories/ad_config_repository.dart';
import '../repositories/buy_list_repository.dart';
import '../repositories/buy_prediction_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/item_type_repository.dart';
import '../repositories/price_repository.dart';

/// リポジトリをまとめて生成・キャッシュするファクトリクラス（アプリ全体共有）
class RepositoryFactory {
  RepositoryFactory._internal();

  /// シングルトンインスタンス（リポジトリの生成元）
  static final RepositoryFactory instance = RepositoryFactory._internal();

  /// _inventoryRepository: 在庫リポジトリのキャッシュ
  InventoryRepository? _inventoryRepository;

  /// _priceRepository: 価格リポジトリのキャッシュ
  PriceRepository? _priceRepository;

  /// _buyListRepository: 買い物リストリポジトリのキャッシュ
  BuyListRepository? _buyListRepository;

  /// _buyPredictionRepository: 買い物予報リポジトリのキャッシュ
  BuyPredictionRepository? _buyPredictionRepository;

  /// _categoryRepository: カテゴリリポジトリのキャッシュ
  CategoryRepository? _categoryRepository;

  /// _itemTypeRepository: アイテム種別リポジトリのキャッシュ
  ItemTypeRepository? _itemTypeRepository;

  /// _adConfigRepository: 広告設定リポジトリのキャッシュ
  AdConfigRepository? _adConfigRepository;

  /// 在庫リポジトリ（在庫画面やホーム画面で使用）
  InventoryRepository get inventoryRepository =>
      _inventoryRepository ??= InventoryRepositoryImpl();

  /// 価格リポジトリ（価格履歴画面で使用）
  PriceRepository get priceRepository =>
      _priceRepository ??= PriceRepositoryImpl();

  /// 買い物リストリポジトリ（買い物リスト画面で使用）
  BuyListRepository get buyListRepository =>
      _buyListRepository ??= BuyListRepositoryImpl();

  /// 買い物予報リポジトリ（ホーム画面の予報カードで使用）
  BuyPredictionRepository get buyPredictionRepository =>
      _buyPredictionRepository ??= BuyPredictionRepositoryImpl();

  /// カテゴリリポジトリ（カテゴリ設定画面で使用）
  CategoryRepository get categoryRepository =>
      _categoryRepository ??= CategoryRepositoryImpl();

  /// アイテム種別リポジトリ（カテゴリ設定画面で使用）
  ItemTypeRepository get itemTypeRepository =>
      _itemTypeRepository ??= ItemTypeRepositoryImpl();

  /// 広告設定リポジトリ（設定画面で使用）
  AdConfigRepository get adConfigRepository =>
      _adConfigRepository ??= AdConfigRepositoryImpl();
}
