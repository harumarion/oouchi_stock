import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../util/firestore_refs.dart';
import '../../data/repositories/ad_config_repository_impl.dart';
import '../../domain/usecases/load_ad_enabled.dart';
import '../../domain/usecases/save_ad_enabled.dart';

/// 設定画面の状態を管理する ViewModel
class SettingsViewModel extends ChangeNotifier {
  /// 最後にバックアップした日時
  DateTime? backupTime;

  /// 最後に復元した日時
  DateTime? restoredTime;

  /// 広告表示設定
  bool adsEnabled = true;

  final LoadAdEnabled _loadAdEnabled;
  final SaveAdEnabled _saveAdEnabled;

  SettingsViewModel()
      : _loadAdEnabled = LoadAdEnabled(AdConfigRepositoryImpl()),
        _saveAdEnabled = SaveAdEnabled(AdConfigRepositoryImpl()) {
    loadTimes();
    loadAds();
  }

  /// バックアップ・復元日時を読み込む
  Future<void> loadTimes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    final backupStr = prefs.getString('backup_time_\$uid');
    final restoreStr = prefs.getString('restore_time_\$uid');
    backupTime = backupStr != null ? DateTime.parse(backupStr) : null;
    restoredTime = restoreStr != null ? DateTime.parse(restoreStr) : null;
    notifyListeners();
  }

  /// 広告設定を読み込む
  Future<void> loadAds() async {
    adsEnabled = await _loadAdEnabled();
    notifyListeners();
  }

  /// 広告設定を保存する
  Future<void> saveAds(bool value) async {
    await _saveAdEnabled(value);
    adsEnabled = value;
    notifyListeners();
  }

  /// データをバックアップする
  Future<void> backup() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    final catSnap = await userCollection('categories').get();
    final invSnap = await userCollection('inventory').get();
    final data = {
      'categories': catSnap.docs.map((d) {
        final m = d.data();
        final ts = m['createdAt'];
        if (ts is Timestamp) m['createdAt'] = ts.toDate().toIso8601String();
        return m;
      }).toList(),
      'inventory': invSnap.docs.map((d) {
        final m = d.data();
        final ts = m['createdAt'];
        if (ts is Timestamp) m['createdAt'] = ts.toDate().toIso8601String();
        return m;
      }).toList(),
    };
    final now = DateTime.now();
    await prefs.setString('backup_$uid', jsonEncode(data));
    await prefs.setString('backup_time_$uid', now.toIso8601String());
    backupTime = now;
    notifyListeners();
  }

  /// バックアップデータから復元する
  Future<DateTime> restore() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString('backup_$uid');
    final timeStr = prefs.getString('backup_time_$uid');
    if (text == null || timeStr == null) {
      throw Exception('no backup');
    }
    final backupTime = DateTime.parse(timeStr);
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
    restoredTime = backupTime;
    notifyListeners();
    return backupTime;
  }
}
