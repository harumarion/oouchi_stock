import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'category_settings_page.dart';
import 'item_type_settings_page.dart';
import 'language_settings_page.dart';
import 'buy_list_condition_settings_page.dart';
import 'domain/entities/category.dart';

/// 設定画面。カテゴリ設定ページへの遷移を提供する
class SettingsPage extends StatelessWidget {
  final List<Category> categories;
  final ValueChanged<List<Category>> onChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onConditionChanged;
  const SettingsPage({
    super.key,
    required this.categories,
    required this.onChanged,
    required this.onLocaleChanged,
    required this.onConditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.categorySettings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategorySettingsPage(
                    initial: categories,
                    onChanged: onChanged,
                  ),
                ),
              );
            },
          ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.itemTypeSettings),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemTypeSettingsPage(categories: categories),
              ),
            );
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.language),
          onTap: () async {
            final locale = await Navigator.push<Locale>(
              context,
              MaterialPageRoute(
                builder: (_) => LanguageSettingsPage(
                  current: Localizations.localeOf(context),
                  onSelected: (l) => Navigator.pop(context, l),
                ),
              ),
            );
            if (locale != null) onLocaleChanged(locale);
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.buyListConditionSettings),
          onTap: () async {
            final changed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => const BuyListConditionSettingsPage(),
              ),
            );
            if (changed == true) onConditionChanged();
          },
        ),
      ],
    ),
  );
  }
}

