import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'domain/entities/inventory.dart';
import 'domain/usecases/add_inventory.dart';
import 'data/repositories/inventory_repository_impl.dart';

// 商品を追加する画面のウィジェット

class AddInventoryPage extends StatefulWidget {
  const AddInventoryPage({super.key});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  // フォームの状態を管理するキー
  final _formKey = GlobalKey<FormState>();
  // 商品名
  String _itemName = '';
  // カテゴリ
  String _category = '日用品';
  // 品種
  String _itemType = '柔軟剤';
  // 数量（小数点第一位まで扱う）
  double _quantity = 1.0;
  // 単位
  String _unit = '個';
  // 任意のメモ
  String _note = '';

  final AddInventory _usecase =
      AddInventory(InventoryRepositoryImpl());

  // 入力内容を Firestore に保存する
  Future<void> _saveItem() async {
    final item = Inventory(
      id: '',
      itemName: _itemName,
      category: _category,
      itemType: _itemType,
      quantity: _quantity,
      unit: _unit,
      note: _note,
      createdAt: DateTime.now(),
    );
    await _usecase(item);
  }

  // カテゴリの選択肢
  List<String> _categories = [];
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _catSub;
  // カテゴリごとの品種一覧
  final Map<String, List<String>> _typesMap = {
    '冷蔵庫': ['その他'],
    '冷凍庫': ['その他'],
    '日用品': [
      '柔軟剤',
      '洗濯洗剤',
      '食洗器洗剤',
      '衣料用漂白剤',
      'シャンプー',
      'コンディショナー',
      'オシャレ洗剤',
      'トイレ洗剤',
      '台所洗剤',
      '台所洗剤スプレー',
      '台所漂白',
      '台所漂白スプレー',
      'トイレ洗剤ふき',
      '台所清掃スプレー',
      'ハンドソープ',
    ],
  };
  // 単位の選択肢
  final List<String> _units = ['個', '本', '袋', 'ロール'];

  @override
  void initState() {
    super.initState();
    _catSub = FirebaseFirestore.instance
        .collection('categories')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _categories =
            snapshot.docs.map((d) => d.data()['name'] as String).toList();
        if (_categories.isNotEmpty && !_categories.contains(_category)) {
          _category = _categories.first;
        }
      });
    });
  }

  @override
  void dispose() {
    _catSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('商品を追加')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // 画面のレイアウトを構築
    return Scaffold(
      appBar: AppBar(title: const Text('商品を追加')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 商品名入力
              TextFormField(
                decoration: const InputDecoration(labelText: '商品名'),
                onChanged: (value) => _itemName = value,
                validator: (value) =>
                    value == null || value.isEmpty ? '商品名は必須です' : null,
              ),
              const SizedBox(height: 12),
              // カテゴリ選択
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'カテゴリ'),
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _category = value;
                    final types = _typesMap[value];
                    if (types != null && types.isNotEmpty) {
                      _itemType = types.first;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              // 品種選択
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '品種'),
                value: _itemType,
                items: (_typesMap[_category] ?? ['その他'])
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) => setState(() => _itemType = value ?? ''),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('数量:'),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => setState(() {
                      // 数量を0.1単位で減らす
                      if (_quantity > 0.1) _quantity -= 0.1;
                      _quantity = double.parse(_quantity.toStringAsFixed(1));
                    }),
                  ),
                  Text(_quantity.toStringAsFixed(1)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() {
                      // 数量を0.1単位で増やす
                      _quantity += 0.1;
                      _quantity = double.parse(_quantity.toStringAsFixed(1));
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 単位選択
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '単位'),
                value: _unit,
                items: _units
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (value) => setState(() => _unit = value!),
              ),
              const SizedBox(height: 12),
              // メモの入力（任意）
              TextFormField(
                decoration: const InputDecoration(labelText: 'メモ（任意）'),
                onChanged: (value) => _note = value,
              ),
              const SizedBox(height: 24),
              // 入力内容を保存するボタン
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('保存'),
                onPressed: () async {
                  // フォームの入力が正しいか確認
                  if (_formKey.currentState!.validate()) {
                    try {
                      await _saveItem();
                      if (!mounted) return;
                      final snackBar = ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('保存完了')),
                      );
                      await snackBar.closed;
                      if (!mounted) return;
                      Navigator.pop(context);
                    } on FirebaseException catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '保存に失敗しました: ${e.message ?? e.code}',
                            ),
                          ),
                        );
                      }
                    } catch (_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('保存に失敗しました')),
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
