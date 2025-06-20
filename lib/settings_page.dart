import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'category_settings_page.dart';
import 'item_type_settings_page.dart';
import 'language_settings_page.dart';
import 'buy_list_condition_settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'util/firestore_refs.dart';
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
  /// 最後にバックアップした日時
  DateTime? _backupTime;

  /// 最後に復元したバックアップデータの日時
  DateTime? _restoredTime;

  @override
  void initState() {
    super.initState();
    _loadTimes();
  }

  /// 端末に保存されたバックアップ日時を読み込む
  Future<void> _loadTimes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    final backupStr = prefs.getString('backup_time_\$uid');
    final restoreStr = prefs.getString('restore_time_\$uid');
    if (!mounted) return;
    setState(() {
      _backupTime = backupStr != null ? DateTime.parse(backupStr) : null;
      _restoredTime = restoreStr != null ? DateTime.parse(restoreStr) : null;
    });
  }
  /// バックアップ実行前に確認ダイアログを表示する
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

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    final catSnap = await userCollection('categories').get();
    final invSnap = await userCollection('inventory').get();
    final data = {
      'categories': catSnap.docs.map((d) => d.data()).toList(),
      'inventory': invSnap.docs.map((d) => d.data()).toList(),
    };
    final now = DateTime.now();
    await prefs.setString('backup_$uid', jsonEncode(data));
    await prefs.setString('backup_time_$uid', now.toIso8601String());
    if (mounted) {
      final time = DateFormat('yyyy/MM/dd HH:mm').format(now);
      setState(() {
        _backupTime = now;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.backupDoneWithTime(time))),
      );
    }
  }

  /// SharedPreferences に保存したバックアップからデータを復元する
  Future<void> _restore() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString('backup_$uid');
    final timeStr = prefs.getString('backup_time_$uid');
    if (text == null || timeStr == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noBackupData)),
        );
      }
      return;
    }
    final backupTime = DateTime.parse(timeStr);
    final formatted = DateFormat('yyyy/MM/dd HH:mm').format(backupTime);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(AppLocalizations.of(context)!.restoreConfirm(formatted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)!.ok)),
        ],
      ),
    );
    if (confirm != true) return;

    final data = jsonDecode(text);
    final batch = FirebaseFirestore.instance.batch();
    final catRef = userCollection('categories');
    final invRef = userCollection('inventory');
    final catDocs = await catRef.get();
    for (final d in catDocs.docs) {
      batch.delete(d.reference);
    }
    final invDocs = await invRef.get();
    for (final d in invDocs.docs) {
      batch.delete(d.reference);
    }
    for (final c in (data['categories'] as List)) {
      batch.set(catRef.doc(), Map<String, dynamic>.from(c));
    }
    for (final i in (data['inventory'] as List)) {
      batch.set(invRef.doc(), Map<String, dynamic>.from(i));
    }
    await batch.commit();
    await prefs.setString('restore_time_$uid', backupTime.toIso8601String());
    if (mounted) {
      setState(() {
        _restoredTime = backupTime;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.restoreDoneWithTime(formatted))),
      );
    }
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
        ListTile(
          key: const Key('backupTile'),
          title: Text(AppLocalizations.of(context)!.backup),
          trailing: _backupTime != null
              ? Text(DateFormat('yyyy/MM/dd HH:mm').format(_backupTime!))
              : null,
          onTap: _backup,
        ),
        ListTile(
          key: const Key('restoreTile'),
          title: Text(AppLocalizations.of(context)!.restore),
          trailing: _restoredTime != null
              ? Text(DateFormat('yyyy/MM/dd HH:mm').format(_restoredTime!))
              : null,
          onTap: _restore,
        ),
      ],
    ),
  );
  }
}

