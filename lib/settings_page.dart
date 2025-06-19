import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'category_settings_page.dart';
import 'item_type_settings_page.dart';
import 'language_settings_page.dart';
import 'buy_list_condition_settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  /// Firestore データを SharedPreferences に保存する簡易バックアップ
  Future<void> _backup() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    final catSnap = await userCollection('categories').get();
    final invSnap = await userCollection('inventory').get();
    final data = {
      'categories': catSnap.docs.map((d) => d.data()).toList(),
      'inventory': invSnap.docs.map((d) => d.data()).toList(),
    };
    await prefs.setString('backup_$uid', jsonEncode(data));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.backupDone)));
    }
  }

  /// SharedPreferences に保存したバックアップからデータを復元する
  Future<void> _restore() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString('backup_$uid');
    if (text == null) return;
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
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.restoreDone)));
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
          title: Text(AppLocalizations.of(context)!.backup),
          onTap: _backup,
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.restore),
          onTap: _restore,
        ),
      ],
    ),
  );
  }
}

