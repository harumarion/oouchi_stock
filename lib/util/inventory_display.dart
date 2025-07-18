import 'package:flutter/widgets.dart';
import '../domain/entities/inventory.dart';
import '../i18n/app_localizations.dart';
import 'unit_localization.dart';

/// 在庫数量と総容量をフォーマットして返すユーティリティ
/// ホーム画面や買い物予報画面などで使用する
String formatRemaining(BuildContext context, Inventory inv) {
  final loc = AppLocalizations.of(context)!;
  final unit = localizeUnit(context, inv.unit);
  final count = inv.quantity.toStringAsFixed(1);
  // totalVolume が 0 の場合は数量と容量から計算
  final total = (inv.totalVolume > 0
          ? inv.totalVolume
          : inv.calculateTotalVolume())
      .toStringAsFixed(1);
  // remainingFormat の引数は (数量, 単位, 総容量) の順で指定する
  return loc.remainingFormat(count, unit, total);
}
