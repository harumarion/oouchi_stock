import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';

/// 正の数値かを検証するバリデータ
String? positiveNumberValidator(BuildContext context, String? value) {
  final v = double.tryParse(value ?? '');
  if (v == null || v <= 0) {
    return AppLocalizations.of(context)!.positiveNumber;
  }
  return null;
}

/// 0以上の数値かを検証するバリデータ
String? nonNegativeNumberValidator(BuildContext context, String? value) {
  final v = double.tryParse(value ?? '');
  if (v == null || v < 0) {
    return AppLocalizations.of(context)!.nonNegativeNumber;
  }
  return null;
}
