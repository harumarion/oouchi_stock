import 'dart:async';
// Flutter の基本ウィジェットとステート管理を使用
import 'package:flutter/material.dart' hide Category;
import '../../domain/entities/inventory.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/update_inventory.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../util/firestore_refs.dart';
import '../../util/date_time_parser.dart';
import '../../default_item_types.dart';

/// 在庫編集画面の状態を管理する ViewModel
class EditInventoryViewModel extends ChangeNotifier {
  /// 在庫更新ユースケース
  final UpdateInventory _usecase = UpdateInventory(InventoryRepositoryImpl());

  /// フォームキー
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// 在庫ID
  String id = '';
  /// 商品名
  String itemName = '';
  /// 選択中カテゴリ
  Category? category;
  /// 品種
  String itemType = '';
  /// 単位
  String unit = '個';
  /// メモ
  String note = '';

  /// カテゴリ一覧
  List<Category> categories = [];
  /// 読み込み済みか
  bool categoriesLoaded = false;
  StreamSubscription? _catSub;

  /// 品種マップ
  Map<String, List<String>> typesMap = {};
  StreamSubscription? _typeSub;

  /// 単位の選択肢
  final List<String> units = const ['個', '本', '袋', 'ロール'];

  EditInventoryViewModel();

  /// 初期データを読み込む
  void load({required String id, required String itemName, required Category category, required String itemType, required String unit, required String note, List<Category>? initialCategories}) {
    this.id = id;
    this.itemName = itemName;
    this.category = category;
    this.itemType = itemType;
    this.unit = unit;
    this.note = note;
    if (initialCategories != null && initialCategories.isNotEmpty) {
      categories = List.from(initialCategories);
      categoriesLoaded = true;
      notifyListeners();
    } else {
      _catSub = userCollection('categories')
          .orderBy('createdAt')
          .snapshots()
          .listen((snapshot) {
        categories = snapshot.docs.map((d) {
          final data = d.data();
          return Category(
            id: data['id'] ?? 0,
            name: data['name'] ?? '',
            createdAt: parseDateTime(data['createdAt']),
            color: data['color'],
          );
        }).toList();
        if (categories.isNotEmpty) {
          final matched = categories.firstWhere(
            (c) => c.id == this.category?.id,
            orElse: () => categories.first,
          );
          category = matched;
        }
        categoriesLoaded = true;
        notifyListeners();
      });
    }
    _typeSub = userCollection('itemTypes')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        await insertDefaultItemTypes();
        return;
      }
      typesMap = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final cat = data['category'] ?? '';
        final name = data['name'] ?? '';
        final list = typesMap.putIfAbsent(cat, () => []);
        if (!list.contains(name)) list.add(name);
      }
      final types = typesMap[category?.name];
      if (types != null && types.isNotEmpty) {
        if (!types.contains(itemType)) itemType = types.first;
      } else {
        itemType = 'その他';
      }
      notifyListeners();
    });
  }

  /// カテゴリ変更処理
  void changeCategory(Category value) {
    category = value;
    final types = typesMap[value.name];
    if (types != null && types.isNotEmpty) {
      itemType = types.first;
    } else {
      itemType = 'その他';
    }
    notifyListeners();
  }

  /// 品種変更処理
  void changeItemType(String value) {
    itemType = value;
    notifyListeners();
  }

  /// 単位設定処理
  void setUnit(String value) {
    unit = value;
    notifyListeners();
  }

  /// メモ設定処理
  void setNote(String value) {
    note = value;
  }

  /// 商品名設定処理
  void setItemName(String value) {
    itemName = value;
  }

  /// 更新処理
  Future<void> save() async {
    final item = Inventory(
      id: id,
      itemName: itemName,
      category: category?.name ?? '',
      itemType: itemType,
      quantity: 0,
      unit: unit,
      note: note,
      createdAt: DateTime.now(),
    );
    await _usecase(item);
  }

  /// 監視解除
  void disposeSubscriptions() {
    _catSub?.cancel();
    _typeSub?.cancel();
  }
}
