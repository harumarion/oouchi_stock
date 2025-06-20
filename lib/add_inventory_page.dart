import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_refs.dart';
import 'util/date_time_parser.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/category.dart';
import 'default_item_types.dart';
import 'domain/usecases/add_inventory.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'widgets/settings_menu_button.dart';
import 'main.dart';

// 商品を追加する画面のウィジェット

class AddInventoryPage extends StatefulWidget {
  final List<Category>? categories;
  const AddInventoryPage({super.key, this.categories});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  // フォームの状態を管理するキー
  final _formKey = GlobalKey<FormState>();
  // 商品名
  String _itemName = '';
  // カテゴリ
  Category? _category;
  // 品種
  String _itemType = '柔軟剤';
  // 数量（整数で管理）
  double _quantity = 1.0;
  // 単位
  String _unit = '個';
  // 任意のメモ
  String _note = '';

  final AddInventory _usecase =
      AddInventory(InventoryRepositoryImpl());

  /// 保存ボタンの処理。入力内容を Firestore に保存する
  Future<void> _saveItem() async {
    final item = Inventory(
      id: '',
      itemName: _itemName,
      category: _category?.name ?? '',
      itemType: _itemType,
      quantity: _quantity,
      unit: _unit,
      note: _note,
      createdAt: DateTime.now(),
    );
    await _usecase(item);
  }

  // カテゴリの選択肢
  List<Category> _categories = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _catSub;
  // カテゴリごとの品種一覧
  Map<String, List<String>> _typesMap = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _typeSub;
  // 単位の選択肢
  final List<String> _units = ['個', '本', '袋', 'ロール'];

  @override
  void initState() {
    super.initState();
    if (widget.categories != null) {
      _categories = List.from(widget.categories!);
      if (_categories.isNotEmpty) {
        _category = _categories.first;
      }
    } else {
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
          if (_categories.isNotEmpty &&
              _categories.every(
                  (c) => c.id != _category?.id && c.name != _category?.name)) {
            _category = _categories.first;
          }
        });
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
      setState(() {
        _typesMap = {};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final cat = data['category'] ?? '';
          final name = data['name'] ?? '';
          _typesMap.putIfAbsent(cat, () => []).add(name);
        }
        if (_category != null) {
          final types = _typesMap[_category!.name];
          if (types != null && types.isNotEmpty) {
            _itemType = types.first;
          } else {
            // 品種が存在しない場合は "その他" を初期値とする
            _itemType = 'その他';
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _catSub?.cancel();
    _typeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventoryAddTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // 画面のレイアウトを構築
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.inventoryAddTitle),
        actions: [
          // 設定メニュー。買い物リスト画面と同じ内容を表示
          SettingsMenuButton(
            categories: _categories,
            onCategoriesChanged: (l) => setState(() => _categories = List.from(l)),
            onLocaleChanged: (l) =>
                context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
            onConditionChanged: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 商品名入力
              TextFormField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.itemName),
                onChanged: (value) => _itemName = value,
                validator: (value) =>
                    value == null || value.isEmpty ? AppLocalizations.of(context)!.itemNameRequired : null,
              ),
              const SizedBox(height: 12),
              // カテゴリ選択
              DropdownButtonFormField<Category>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.category),
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _category = value;
                    final types = _typesMap[value.name];
                    if (types != null && types.isNotEmpty) {
                      _itemType = types.first;
                    } else {
                      // 品種が存在しないカテゴリを選んだ場合は "その他" に変更
                      _itemType = 'その他';
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              // 品種選択
              Builder(builder: (context) {
                // 現在選択中のカテゴリに対応する品種リストを取得
                final itemTypes = _typesMap[_category?.name] ?? ['その他'];
                // ドロップダウンに存在しない値を選んでいる場合は先頭に合わせる
                if (!itemTypes.contains(_itemType)) {
                  _itemType = itemTypes.first;
                }
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.itemType),
                  value: _itemType,
                  items: itemTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) => setState(() => _itemType = value ?? ''),
                );
              }),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('${AppLocalizations.of(context)!.quantity}:'),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => setState(() {
                      // 商品追加画面: 数量を1単位で減らす
                      if (_quantity > 1.0) _quantity -= 1.0;
                      _quantity = double.parse(_quantity.toStringAsFixed(0));
                    }),
                  ),
                  Text(_quantity.toStringAsFixed(0)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() {
                      // 商品追加画面: 数量を1単位で増やす
                      _quantity += 1.0;
                      _quantity = double.parse(_quantity.toStringAsFixed(0));
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 単位選択
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.unit),
                value: _unit,
                items: _units
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (value) => setState(() => _unit = value!),
              ),
              const SizedBox(height: 12),
              // メモの入力（任意）
              TextFormField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.memoOptional),
                onChanged: (value) => _note = value,
              ),
              const SizedBox(height: 24),
              // 入力内容を保存するボタン
              // 保存ボタン。入力が正しい場合は Firestore へ登録
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(AppLocalizations.of(context)!.save),
                onPressed: () async {
                  // フォームの入力が正しいか確認
                  if (_formKey.currentState!.validate()) {
                    try {
                      await _saveItem();
                      if (!mounted) return;
                      final snackBar = ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.saved)),
                      );
                      await snackBar.closed;
                      if (!mounted) return;
                      // 画面がスタックに積まれている場合のみ前の画面へ戻る
                      if (Navigator.of(context).canPop()) {
                        Navigator.pop(context);
                      } else {
                        // ルート画面から商品追加した場合はフォームをリセットする
                        setState(() {
                          _formKey.currentState?.reset();
                          _itemName = '';
                          _note = '';
                          _quantity = 1.0;
                        });
                      }
                    } on FirebaseException catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${AppLocalizations.of(context)!.saveFailed}: ${e.message ?? e.code}'),
                          ),
                        );
                      }
                    } catch (_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.saveFailed)),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
