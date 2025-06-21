import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_refs.dart';
import 'util/date_time_parser.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/category.dart';
import 'domain/usecases/update_inventory.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'add_category_page.dart';
import 'default_item_types.dart';

/// 商品を編集する画面のウィジェット
class EditInventoryPage extends StatefulWidget {
  final String id;
  final String itemName;
  final Category category;
  final String itemType;
  final String unit;
  final String note;
  const EditInventoryPage({
    super.key,
    required this.id,
    required this.itemName,
    required this.category,
    required this.itemType,
    required this.unit,
    required this.note,
  });

  @override
  State<EditInventoryPage> createState() => _EditInventoryPageState();
}

class _EditInventoryPageState extends State<EditInventoryPage> {
  // フォーム状態を管理するキー
  final _formKey = GlobalKey<FormState>();
  // 商品名
  late String _itemName;
  // 選択中のカテゴリ
  late Category _category;
  // 品種
  late String _itemType;
  // 単位
  late String _unit;
  // メモ
  late String _note;

  // 在庫更新ユースケース
  final UpdateInventory _usecase =
      UpdateInventory(InventoryRepositoryImpl());

  // 取得したカテゴリ一覧
  List<Category> _categories = [];
  // カテゴリが読み込まれたかどうか
  bool _categoriesLoaded = false;
  // カテゴリ更新監視用の購読
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _catSub;
  // カテゴリごとの品種マップ
  Map<String, List<String>> _typesMap = {};
  // 品種更新監視用の購読
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _typeSub;
  // 単位の選択肢
  final List<String> _units = ['個', '本', '袋', 'ロール'];

  @override
  void initState() {
    super.initState();
    _itemName = widget.itemName;
    _category = widget.category;
    _itemType = widget.itemType;
    _unit = widget.unit;
    _note = widget.note;
    // カテゴリコレクションの更新を監視
    _catSub = userCollection('categories')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _categories = snapshot.docs.map((d) {
          final data = d.data();
          return Category(
            id: data['id'] ?? 0,
            name: data['name'] ?? '',
            createdAt: parseDateTime(data['createdAt']),
            color: data['color'],
          );
        }).toList();
        if (_categories.isNotEmpty) {
          // id が一致するカテゴリを最新のリストから取得
          final matched = _categories.firstWhere(
            (c) => c.id == _category.id,
            orElse: () => _categories.first,
          );
          _category = matched;
          // カテゴリ変更に合わせて品種を更新
          final types = _typesMap[_category.name];
          if (types != null && types.isNotEmpty) {
            _itemType = types.contains(_itemType) ? _itemType : types.first;
          } else {
            // 品種が存在しないカテゴリを選択中の場合は "その他" を設定
            _itemType = 'その他';
          }
        }
        _categoriesLoaded = true;
      });
    });
    // 品種コレクションの更新を監視
    _typeSub = userCollection('itemTypes')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        await insertDefaultItemTypes();
        return;
      }
      setState(() {
        _typesMap = {};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final cat = data['category'] ?? '';
          final name = data['name'] ?? '';
          // Firestore 上に重複した品種があっても一意になるようチェック
          final list = _typesMap.putIfAbsent(cat, () => []);
          if (!list.contains(name)) list.add(name);
        }
        final types = _typesMap[_category.name];
        if (types != null && types.isNotEmpty) {
          _itemType = types.contains(_itemType) ? _itemType : types.first;
        } else {
          // 対応する品種が無い場合は "その他" を設定
          _itemType = 'その他';
        }
      });
    });
  }

  /// 保存ボタンを押したときの処理
  Future<void> _saveItem() async {
    final item = Inventory(
      id: widget.id,
      itemName: _itemName,
      category: _category.name,
      itemType: _itemType,
      quantity: 0,
      unit: _unit,
      note: _note,
      createdAt: DateTime.now(),
    );
    await _usecase(item);
  }

  @override
  void dispose() {
    _catSub.cancel();
    _typeSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // カテゴリがまだ読み込まれていない場合はローディング
    if (!_categoriesLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventoryEditTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // カテゴリが存在しない場合は追加を促す画面を表示
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventoryEditTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.noCategories),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddCategoryPage()),
                  );
                },
                child: Text(AppLocalizations.of(context)!.addCategory),
              ),
            ],
          ),
        ),
      );
    }
    // 商品編集フォームを表示
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventoryEditTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _itemName,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.itemName),
                onChanged: (v) => _itemName = v,
                validator: (v) =>
                    v == null || v.isEmpty ? AppLocalizations.of(context)!.itemNameRequired : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Category>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.category),
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    // カテゴリ変更時に選択中の品種も更新する
                    _category = v;
                    final types = _typesMap[v.name];
                    if (types != null && types.isNotEmpty) {
                      _itemType = types.first;
                    } else {
                      // 品種が無いカテゴリを選択した場合は "その他" を適用
                      _itemType = 'その他';
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              Builder(builder: (context) {
                // 選択中カテゴリに該当する品種リストを取得
                final itemTypes = _typesMap[_category.name] ?? ['その他'];
                if (!itemTypes.contains(_itemType)) {
                  _itemType = itemTypes.first;
                }
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.itemType),
                  value: _itemType,
                  items: itemTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _itemType = v ?? ''),
                );
              }),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.unit),
                value: _unit,
                items:
                    _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (v) => setState(() => _unit = v ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _note,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.memo),
                onChanged: (v) => _note = v,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(AppLocalizations.of(context)!.save),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _saveItem();
                    if (mounted) Navigator.pop(context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
