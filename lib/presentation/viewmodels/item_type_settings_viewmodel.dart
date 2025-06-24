import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../util/firestore_refs.dart';
import '../../util/date_time_parser.dart';
import '../../domain/entities/item_type.dart';
import '../../default_item_types.dart';

/// 品種設定画面の状態を管理する ViewModel
class ItemTypeSettingsViewModel extends ChangeNotifier {
  final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _sub;
  List<ItemType> list = [];

  ItemTypeSettingsViewModel() : _sub = userCollection('itemTypes')
          .orderBy('createdAt')
          .snapshots()
          .listen((snapshot) async {}) {
    _sub.onData((snapshot) async {
      if (snapshot.docs.isEmpty) {
        await insertDefaultItemTypes();
        return;
      }
      list = snapshot.docs.map((d) {
        final data = d.data();
        return ItemType(
          id: data['id'] ?? 0,
          category: data['category'] ?? '',
          name: data['name'] ?? '',
          createdAt: parseDateTime(data['createdAt']),
        );
      }).toList();
      notifyListeners();
    });
  }

  /// 品種を削除する
  Future<void> delete(ItemType item) async {
    try {
      final snapshot = await userCollection('itemTypes')
          .where('id', isEqualTo: item.id)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('品種削除失敗: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
