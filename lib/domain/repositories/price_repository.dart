import '../entities/price_info.dart';

abstract class PriceRepository {
  Future<String> addPriceInfo(PriceInfo info);
  Stream<List<PriceInfo>> watchByCategory(String category);
  Stream<List<PriceInfo>> watchByType(String category, String itemType);
  Future<void> deletePriceInfo(String id);
}
