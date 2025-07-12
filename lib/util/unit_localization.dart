import '../i18n/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// 単位文字列をローカライズするためのユーティリティ
/// [unit] はデータベースに保存されている日本語表記
/// 例: "個", "本", "袋", "ロール", "リットル"
String localizeUnit(BuildContext context, String unit) {
  final loc = AppLocalizations.of(context)!;
  switch (unit) {
    case '個':
      return loc.unitPiece;
    case '本':
      return loc.unitBottle;
    case '袋':
      return loc.unitBag;
    case 'ロール':
      return loc.unitRoll;
    case 'リットル':
      return loc.unitLiter;
    default:
      return unit;
  }
}
