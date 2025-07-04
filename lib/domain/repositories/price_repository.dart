import '../entities/price_info.dart';

/// セール情報を扱うリポジトリ
abstract class PriceRepository {
  /// セール情報を追加してIDを返す
  Future<String> addPriceInfo(PriceInfo info);

  /// カテゴリ単位でセール情報を監視する
  Stream<List<PriceInfo>> watchByCategory(String category);

  /// カテゴリと品種でセール情報を監視する
  Stream<List<PriceInfo>> watchByType(String category, String itemType);

  /// 情報を削除する
  Future<void> deletePriceInfo(String id);
}
