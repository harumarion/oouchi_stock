import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_order.dart';
import '../../util/firestore_refs.dart';
import '../../util/date_time_parser.dart';

/// セール情報管理画面全体の状態を管理する ViewModel
class PriceListViewModel extends ChangeNotifier {
  /// カテゴリ一覧
  List<Category> categories = [];

  /// 読み込み完了フラグ
  bool loaded = false;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  /// Firestore からカテゴリを読み込み監視する
  Future<void> load() async {
    _sub = userCollection('categories')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) async {
      var list = snapshot.docs.map((d) {
        final data = d.data();
        return Category(
          id: data['id'] ?? 0,
          name: data['name'] ?? '',
          createdAt: parseDateTime(data['createdAt']),
        );
      }).toList();
      list = await applyCategoryOrder(list);
      categories = list;
      loaded = true;
      notifyListeners();
    }, onError: (_) {
      loaded = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
