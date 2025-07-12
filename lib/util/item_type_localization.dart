import '../i18n/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// 品種名をローカライズするユーティリティ
/// Firestore上には日本語名で保存されているため、
/// 画面表示時に各言語へ変換する
String localizeItemType(BuildContext context, String type) {
  final loc = AppLocalizations.of(context)!;
  switch (type) {
    case 'その他':
      return loc.itemTypeOther;
    default:
      return type;
  }
}
