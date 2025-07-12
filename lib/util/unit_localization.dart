import '../i18n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'constants.dart';

/// 単位文字列をローカライズするためのユーティリティ
/// [unit] はデータベースに保存されている日本語表記
/// 例: "個", "本", "袋", "ロール", "リットル"
String localizeUnit(BuildContext context, String unit) {
  final loc = AppLocalizations.of(context)!;
  switch (unit) {
    case defaultUnits[0]:
      return loc.unitPiece;
    case defaultUnits[1]:
      return loc.unitBottle;
    case defaultUnits[2]:
      return loc.unitBag;
    case defaultUnits[3]:
      return loc.unitRoll;
    case defaultUnits[4]:
      return loc.unitLiter;
    default:
      return unit;
  }
}
