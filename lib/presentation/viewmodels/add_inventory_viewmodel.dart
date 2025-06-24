import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/add_inventory.dart';
import '../../util/firestore_refs.dart';
import '../../util/date_time_parser.dart';
import '../../default_item_types.dart';

/// 商品追加画面の状態を管理する ViewModel
class AddInventoryViewModel extends ChangeNotifier {
  /// 在庫追加ユースケース
  final AddInventory _usecase;

  /// フォームキー
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// 商品名
  String itemName = '';

  /// 選択中のカテゴリ
  Category? category;

  /// 品種
  String itemType = '柔軟剤';

  /// 数量
  double quantity = 1.0;

  /// 1個あたり容量
  double volume = 1.0;

  /// 単位
  String unit = '個';

  /// メモ
  String note = '';

  /// カテゴリ一覧
  List<Category> categories = [];

  /// カテゴリが読み込まれたか
  bool categoriesLoaded = false;

  StreamSubscription? _catSub;
  Map<String, List<String>> typesMap = {};
  StreamSubscription? _typeSub;

  /// 単位の選択肢
  final List<String> units = ['個', '本', '袋', 'ロール'];

  AddInventoryViewModel(this._usecase);

  /// 総容量を計算
  double get totalVolume => quantity * volume;

  /// 初期データ読み込み
  void load(List<Category>? initialCategories) {
    if (initialCategories != null && initialCategories.isNotEmpty) {
      categories = List.from(initialCategories);
      category = categories.first;
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
        if (categories.isNotEmpty &&
            categories.every((c) => c.id != category?.id && c.name != category?.name)) {
          category = categories.first;
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
        typesMap.putIfAbsent(cat, () => []).add(name);
      }
      if (category != null) {
        final types = typesMap[category!.name];
        if (types != null && types.isNotEmpty) {
          itemType = types.first;
        } else {
          itemType = 'その他';
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
      itemType = 'その他';
    }
    notifyListeners();
  }

  /// 品種変更処理
  void changeItemType(String value) {
    itemType = value;
    notifyListeners();
  }

  /// 個数増減処理
  void changeQuantity(double delta) {
    quantity += delta;
    if (quantity < 1.0) quantity = 1.0;
    quantity = double.parse(quantity.toStringAsFixed(0));
    notifyListeners();
  }

  /// 容量設定処理
  void setVolume(String v) {
    volume = double.tryParse(v) ?? 1.0;
    notifyListeners();
  }

  /// 単位設定処理
  void setUnit(String v) {
    unit = v;
    notifyListeners();
  }

  /// メモ設定処理
  void setNote(String v) {
    note = v;
  }

  /// 商品名設定処理
  void setItemName(String v) {
    itemName = v;
  }

  /// 在庫保存
  Future<void> save() async {
    final item = Inventory(
      id: '',
      itemName: itemName,
      category: category?.name ?? '',
      itemType: itemType,
      quantity: quantity,
      volume: volume,
      totalVolume: quantity * volume,
      unit: unit,
      note: note,
      monthlyConsumption: 0,
      createdAt: DateTime.now(),
    );
    await _usecase(item);
  }

  /// 監視を解除
  void disposeSubscriptions() {
    _catSub?.cancel();
    _typeSub?.cancel();
  }
}
