import '../entities/buy_item.dart';
import '../usecases/purchase_decision.dart';
import '../entities/purchase_decision_settings.dart' as purchase_settings;

/// エンティティ生成と関連設定処理を担うファクトリクラス（ユースケースに付随）
class EntityFactory {
  EntityFactory._internal();

  /// instance: シングルトンインスタンス
  static final EntityFactory instance = EntityFactory._internal();

  /// 買い物リストアイテムを生成（ホーム画面・買い物リスト画面で使用）
  BuyItem createBuyItem(
    String name,
    String category,
    String? inventoryId,
    BuyItemReason reason,
  ) =>
      BuyItem(name, category, inventoryId, reason);

  /// 購入判定ユースケースで利用する PurchaseDecision を生成
  PurchaseDecision createPurchaseDecision({
    required double threshold,
    required purchase_settings.PurchaseDecisionSettings settings,
  }) =>
      PurchaseDecision(
        threshold,
        cautiousDays: settings.cautiousDays,
        bestTimeDays: settings.bestTimeDays,
        discountPercent: settings.discountPercent,
      );

  /// 購入判定設定を読み込む（設定画面で使用）
  Future<purchase_settings.PurchaseDecisionSettings>
      loadPurchaseDecisionSettings() =>
          purchase_settings.loadPurchaseDecisionSettings();

  /// 購入判定設定を保存する（設定画面で使用）
  Future<void> savePurchaseDecisionSettings(
    purchase_settings.PurchaseDecisionSettings settings,
  ) =>
      purchase_settings.savePurchaseDecisionSettings(settings);
}
