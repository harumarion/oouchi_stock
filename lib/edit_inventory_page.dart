import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/category.dart';
import 'domain/usecases/update_inventory.dart';
import 'data/repositories/inventory_repository_impl.dart';

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
  final _formKey = GlobalKey<FormState>();
  late String _itemName;
  late Category _category;
  late String _itemType;
  late String _unit;
  late String _note;

  final UpdateInventory _usecase =
      UpdateInventory(InventoryRepositoryImpl());

  List<Category> _categories = [];
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _catSub;
  final Map<String, List<String>> _typesMap = {
    '冷蔵庫': ['その他'],
    '冷凍庫': ['その他'],
    '日用品': ['柔軟剤', '洗濯洗剤', '食洗器洗剤', '衣料用漂白剤']
  };
  final List<String> _units = ['個', '本', '袋', 'ロール'];

  @override
  void initState() {
    super.initState();
    _itemName = widget.itemName;
    _category = widget.category;
    _itemType = widget.itemType;
    _unit = widget.unit;
    _note = widget.note;
    _catSub = FirebaseFirestore.instance
        .collection('categories')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _categories = snapshot.docs.map((d) {
          final data = d.data();
          return Category(
            id: data['id'] ?? 0,
            name: data['name'] ?? '',
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          );
        }).toList();
        if (_categories.isNotEmpty &&
            _categories.every(
                (c) => c.id != _category.id && c.name != _category.name)) {
          _category = _categories.first;
        }
      });
    });
  }

  /// 保存ボタンの処理
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('商品編集')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('商品編集')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _itemName,
                decoration: const InputDecoration(labelText: '商品名'),
                onChanged: (v) => _itemName = v,
                validator: (v) =>
                    v == null || v.isEmpty ? '商品名は必須です' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Category>(
                decoration: const InputDecoration(labelText: 'カテゴリ'),
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _category = v;
                    final types = _typesMap[v.name];
                    if (types != null && types.isNotEmpty) {
                      _itemType = types.first;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '品種'),
                value: _itemType,
                items: (_typesMap[_category.name] ?? ['その他'])
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _itemType = v ?? ''),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '単位'),
                value: _unit,
                items:
                    _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (v) => setState(() => _unit = v ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _note,
                decoration: const InputDecoration(labelText: 'メモ'),
                onChanged: (v) => _note = v,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('保存'),
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
