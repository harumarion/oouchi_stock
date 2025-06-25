import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'category_settings_page.dart';
import 'item_type_settings_page.dart';
import 'language_settings_page.dart';
import 'buy_list_condition_settings_page.dart';
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
                    initial: widget.categories,
                    onChanged: widget.onChanged,
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
                  builder: (_) => ItemTypeSettingsPage(categories: widget.categories),
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
              if (locale != null) widget.onLocaleChanged(locale);
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
              if (changed == true) widget.onConditionChanged();
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.showAds),
            value: _viewModel.adsEnabled,
            onChanged: (v) => _viewModel.saveAds(v),
          ),
          ListTile(
            key: const Key('backupTile'),
            title: Text(AppLocalizations.of(context)!.backup),
            trailing: Text(
              _viewModel.backupTime != null
                  ? DateFormat('yyyy/MM/dd HH:mm').format(_viewModel.backupTime!)
                  : AppLocalizations.of(context)!.noBackupYet,
            ),
            onTap: _backup,
          ),
          ListTile(
            key: const Key('restoreTile'),
            title: Text(AppLocalizations.of(context)!.restore),
            trailing: Text(
              _viewModel.restoredTime != null
                  ? DateFormat('yyyy/MM/dd HH:mm').format(_viewModel.restoredTime!)
                  : AppLocalizations.of(context)!.noRestoreYet,
            ),
            onTap: _restore,
          ),
        ],
      ),
    );
  }
}
