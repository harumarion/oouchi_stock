import '../i18n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'constants.dart';

/// 単位文字列をローカライズするためのユーティリティ
/// [unit] はデータベースに保存されている日本語表記
/// 例: "個", "本", "袋", "ロール", "リットル", "ミリリットル", "グラム", "キログラム"
String localizeUnit(BuildContext context, String unit) {
  final loc = AppLocalizations.of(context)!;
  // 単位ごとにローカライズされた表示名を返す
  if (unit == defaultUnits[0]) {
    return loc.unitPiece;
  } else if (unit == defaultUnits[1]) {
    return loc.unitBottle;
  } else if (unit == defaultUnits[2]) {
    return loc.unitBag;
  } else if (unit == defaultUnits[3]) {
    return loc.unitRoll;
  } else if (unit == defaultUnits[4]) {
    return loc.unitLiter;
  } else if (unit == defaultUnits[5]) {
    return loc.unitMilliliter;
  } else if (unit == defaultUnits[6]) {
    return loc.unitGram;
  } else if (unit == defaultUnits[7]) {
    return loc.unitKilogram;
  } else {
    return unit;
  }
}
