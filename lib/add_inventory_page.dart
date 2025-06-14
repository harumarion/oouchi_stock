import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 在庫を追加する画面のウィジェット

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
  // 数量
  int _quantity = 1;
  // 単位
  String _unit = '個';
  // 任意のメモ
  String _note = '';

  // 入力内容を Firestore に保存する
  Future<void> _saveItem() async {
    await FirebaseFirestore.instance.collection('inventory').add({
      'itemName': _itemName,
      'category': _category,
      'quantity': _quantity,
      'unit': _unit,
      'note': _note,
      'createdAt': Timestamp.now(),
    });
  }

  // カテゴリの選択肢
  final List<String> _categories = ['冷蔵庫', '冷凍庫', '日用品'];
  // 単位の選択肢
  final List<String> _units = ['個', '本', '袋', 'ロール'];

  @override
  Widget build(BuildContext context) {
    // 画面のレイアウトを構築
    return Scaffold(
      appBar: AppBar(title: const Text('在庫を追加')),
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
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('数量:'),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => setState(() {
                      // 数量を減らす
                      if (_quantity > 1) _quantity--;
                    }),
                  ),
                  Text('$_quantity'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() {
                      // 数量を増やす
                      _quantity++;
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
                    await _saveItem();
                    if (mounted) Navigator.pop(context);
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
