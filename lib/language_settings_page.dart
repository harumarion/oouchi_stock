import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

/// 言語設定画面。対応する言語一覧を表示し選択を反映する
class LanguageSettingsPage extends StatelessWidget {
  final Locale current;
  final ValueChanged<Locale> onSelected;
  const LanguageSettingsPage({
    super.key,
    required this.current,
    required this.onSelected,
  });

  /// 表示名を返す
  String _name(BuildContext context, Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        return AppLocalizations.of(context)!.japanese;
      case 'en':
        return AppLocalizations.of(context)!.english;
      default:
        return locale.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locales = AppLocalizations.supportedLocales;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.language)),
      body: ListView(
        children: [
          for (final l in locales)
            RadioListTile<Locale>(
              value: l,
              groupValue: current,
              title: Text(_name(context, l)),
              onChanged: (value) {
                if (value != null) {
                  onSelected(value);
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
    );
  }
}
