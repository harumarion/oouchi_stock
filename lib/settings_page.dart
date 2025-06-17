import 'package:flutter/material.dart';
import 'package:oouchi_stock/l10n/app_localizations.dart';
import 'category_settings_page.dart';
import 'item_type_settings_page.dart';
import 'domain/entities/category.dart';

/// 設定画面。カテゴリ設定ページへの遷移を提供する
class SettingsPage extends StatelessWidget {
  final List<Category> categories;
  final ValueChanged<List<Category>> onChanged;
  const SettingsPage({
    super.key,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).settings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context).categorySettings),
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
            title: Text(AppLocalizations.of(context).itemTypeSettings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemTypeSettingsPage(categories: categories),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

