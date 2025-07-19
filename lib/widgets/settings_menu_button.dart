import 'package:flutter/material.dart';
import '../settings_page.dart';
import '../domain/entities/category.dart';
import '../i18n/app_localizations.dart';

/// 画面右上のメニューから設定画面を開くためのボタン。
class SettingsMenuButton extends StatelessWidget {
  final List<Category> categories; // 設定画面に渡すカテゴリ一覧
  final ValueChanged<List<Category>> onCategoriesChanged; // カテゴリ更新時のコールバック
  final ValueChanged<Locale> onLocaleChanged; // 言語変更時のコールバック
  final VoidCallback onConditionChanged; // 買い物予報条件更新時のコールバック

  const SettingsMenuButton({
    super.key,
    required this.categories,
    required this.onCategoriesChanged,
    required this.onLocaleChanged,
    required this.onConditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'settings') {
          // 設定画面を開く
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SettingsPage(
                categories: categories,
                onChanged: onCategoriesChanged,
                onLocaleChanged: onLocaleChanged,
                onConditionChanged: onConditionChanged,
              ),
            ),
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'settings',
          child: Text(
            AppLocalizations.of(context)!.settings,
            // メニュー項目にはカードタイトルと同じフォントを使用
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
