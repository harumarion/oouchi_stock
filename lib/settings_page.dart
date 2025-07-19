import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'category_settings_page.dart';
import 'item_type_settings_page.dart';
import 'language_settings_page.dart';
import 'buy_list_condition_settings_page.dart';
import 'purchase_decision_settings_page.dart';
import 'package:intl/intl.dart';
import 'presentation/viewmodels/settings_viewmodel.dart';
import 'domain/entities/category.dart';

/// 設定画面。カテゴリ設定ページへの遷移を提供する
class SettingsPage extends StatefulWidget {
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
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel()
      ..addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// バックアップボタン押下時に実行
  Future<void> _backup() async {
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(loc.backupConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.ok)),
        ],
      ),
    );
    if (result != true) return;
    await _viewModel.backup();
    if (!mounted) return;
    final time = DateFormat('yyyy/MM/dd HH:mm').format(_viewModel.backupTime!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.backupDoneWithTime(time))),
    );
  }

  /// 復元ボタン押下時に実行
  Future<void> _restore() async {
    final loc = AppLocalizations.of(context)!;
    final backupTime = _viewModel.backupTime;
    if (backupTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.noBackupData)),
      );
      return;
    }
    final formatted = DateFormat('yyyy/MM/dd HH:mm').format(backupTime);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(loc.restoreConfirm(formatted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.ok)),
        ],
      ),
    );
    if (confirm != true) return;
    final time = await _viewModel.restore();
    if (!mounted) return;
    if (time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.noBackupData)),
      );
      return;
    }
    final t = DateFormat('yyyy/MM/dd HH:mm').format(time);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.restoreDoneWithTime(t))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // データ設定に関するカード
          // カテゴリ設定や品種設定へ遷移するカード
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category),
                  title: Text(loc.categorySettings),
                  subtitle: Text(loc.categorySettingsDesc),
                  // カテゴリ設定画面へ遷移
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategorySettingsPage(
                          initial: widget.categories,
                          onChanged: widget.onChanged,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.label),
                  title: Text(loc.itemTypeSettings),
                  subtitle: Text(loc.itemTypeSettingsDesc),
                  // 品種設定画面へ遷移
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemTypeSettingsPage(categories: widget.categories),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // 言語設定を行うカード
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(loc.language),
              subtitle: Text(loc.languageDesc),
              // 言語設定画面へ遷移
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
                if (locale != null) widget.onLocaleChanged(locale);
              },
            ),
          ),
          // 機能設定に関するカード
          // アプリの機能設定を行うカード
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.playlist_add_check),
                  title: Text(loc.buyListConditionSettings),
                  subtitle: Text(loc.buyListConditionSettingsDesc),
                  // 買い物予報条件設定画面へ遷移
                  onTap: () async {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BuyListConditionSettingsPage(),
                      ),
                    );
                    if (changed == true) widget.onConditionChanged();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: Text(loc.purchaseDecisionSettings),
                  subtitle: Text(loc.purchaseDecisionSettingsDesc),
                  // 購入判定設定画面へ遷移
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PurchaseDecisionSettingsPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                // 広告表示の切り替えスイッチ
                SwitchListTile(
                  title: Text(loc.showAds),
                  subtitle: Text(loc.adsDesc),
                  value: _viewModel.adsEnabled,
                  onChanged: (v) => _viewModel.saveAds(v),
                  secondary: const Icon(Icons.ads_click),
                ),
              ],
            ),
          ),
          // バックアップ・復元に関するカード
          // バックアップと復元をまとめたカード
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // バックアップ実行ボタン
                  FilledButton.icon(
                    key: const Key('backupButton'),
                    onPressed: _backup,
                    icon: const Icon(Icons.backup),
                    label: Text(loc.backup),
                  ),
                  // バックアップ日時の表示
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    child: Text(
                      _viewModel.backupTime != null
                          ? DateFormat('yyyy/MM/dd HH:mm').format(_viewModel.backupTime!)
                          : loc.noBackupYet,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  // 復元実行ボタン
                  FilledButton.icon(
                    key: const Key('restoreButton'),
                    onPressed: _restore,
                    icon: const Icon(Icons.restore),
                    label: Text(loc.restore),
                  ),
                  // 復元日時の表示
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _viewModel.restoredTime != null
                          ? DateFormat('yyyy/MM/dd HH:mm').format(_viewModel.restoredTime!)
                          : loc.noRestoreYet,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
