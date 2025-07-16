import 'dart:async';
// Flutter の基本ウィジェットとステート管理を使用
import 'package:flutter/material.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/update_inventory.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../util/firestore_refs.dart';
import '../../util/date_time_parser.dart';
import '../../default_item_types.dart';
// アプリ共通の定数を利用
import '../../util/constants.dart';

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
  /// 数量
  double quantity = 0;

  /// 1個あたり容量
  double volume = 0;

  /// 単位
  // 初期の単位を定数から取得
  String unit = defaultUnits.first;

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

  /// Firestore から品種リストを受信済みかどうか
  bool typesLoaded = false;

  /// 単位の選択肢
  // ミリリットル、グラム、キログラムも含めた選択肢
  // 選択可能な単位一覧を定数から生成
  final List<String> units = List.from(defaultUnits);

  EditInventoryViewModel();

  /// 初期データを読み込む
  void load({
    required String id,
    required String itemName,
    required Category category,
    required String itemType,
    required double quantity,
    required double volume,
    required String unit,
    required String note,
    List<Category>? initialCategories,
  }) {
    this.id = id;
    this.itemName = itemName;
    this.category = category;
    this.itemType = itemType;
    this.quantity = quantity;
    this.volume = volume;
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
      // Firestore から一覧を取得できたのでフラグを立てる
      typesLoaded = true;
      final types = typesMap[category.name];
      if (types != null && types.isNotEmpty) {
        // 既に設定されている品種がリストにあるかを確認
        if (itemType.isEmpty) {
          itemType = types.first;
        } else if (!types.contains(itemType)) {
          // リストに存在しない場合のみ先頭の品種へ変更
          itemType = types.first;
        }
      } else {
        if (itemType.isEmpty) {
          itemType = itemTypeOther;
        }
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
      itemType = itemTypeOther;
    }
    notifyListeners();
  }

  /// 品種変更処理
  void changeItemType(String value) {
    itemType = value;
    notifyListeners();
  }

  /// 容量設定処理
  void setVolume(String value) {
    final v = double.tryParse(value) ?? 0;
    volume = v;
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
      quantity: quantity,
      volume: volume,
      totalVolume: quantity * volume,
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
