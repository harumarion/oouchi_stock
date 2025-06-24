import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/category_order.dart';
import '../../util/firestore_refs.dart';
import '../../util/date_time_parser.dart';

/// 在庫一覧画面全体の状態を管理する ViewModel
/// カテゴリの読み込みと更新処理を担当する
class InventoryPageViewModel extends ChangeNotifier {
  /// Firestore から取得したカテゴリ一覧
  List<Category> categories = [];

  /// カテゴリが読み込み済みかどうか
  bool categoriesLoaded = false;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _catSub;

  /// 初期カテゴリを読み込み、Firestore 監視を開始する
  Future<void> loadCategories(List<Category>? initial) async {
    if (initial != null && initial.isNotEmpty) {
      categories = List<Category>.from(initial);
      categories = await applyCategoryOrder(categories);
      categoriesLoaded = true;
      notifyListeners();
    } else {
      _catSub = userCollection('categories')
          .orderBy('createdAt')
          .snapshots()
          .listen((snapshot) async {
        var list = snapshot.docs.map((d) {
          final data = d.data();
          return Category(
            id: data['id'] ?? 0,
            name: data['name'] ?? '',
            createdAt: parseDateTime(data['createdAt']),
            color: data['color'],
          );
        }).toList();
        list = await applyCategoryOrder(list);
        categories = list;
        categoriesLoaded = true;
        notifyListeners();
      });
    }
  }

  /// 設定画面から戻った際などにカテゴリリストを更新する
  void updateCategories(List<Category> list) {
    categories = List<Category>.from(list);
    categoriesLoaded = true;
    notifyListeners();
  }

  /// カテゴリ情報を再読み込みする
  Future<void> refresh() async {
    await _catSub?.cancel();
    categoriesLoaded = false;
    await loadCategories(null);
  }

  @override
  void dispose() {
    _catSub?.cancel();
    super.dispose();
  }
}
