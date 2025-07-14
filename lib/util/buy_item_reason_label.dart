import '../domain/entities/buy_item.dart';
import '../i18n/app_localizations.dart';

/// BuyItemReason 列挙値をローカライズ文字列へ変換する拡張
extension BuyItemReasonLabel on BuyItemReason {
  String label(AppLocalizations loc) {
    switch (this) {
      case BuyItemReason.manual:
        return loc.reasonManual;
      case BuyItemReason.inventory:
        return loc.reasonInventory;
      case BuyItemReason.sale:
        return loc.reasonSale;
      case BuyItemReason.prediction:
        return loc.reasonPrediction;
      case BuyItemReason.autoEmergency:
        return loc.reasonAutoEmergency;
      case BuyItemReason.autoBestTime:
        return loc.reasonAutoBestTime;
      case BuyItemReason.autoCautious:
        return loc.reasonAutoCautious;
      case BuyItemReason.autoBulk:
        return loc.reasonAutoBulk;
    }
  }
}
