import 'package:flutter/material.dart';
import 'domain/entities/inventory.dart';
import 'domain/usecases/update_inventory.dart';
import 'data/repositories/inventory_repository_impl.dart';

class EditInventoryPage extends StatefulWidget {
  final String id;
  final String itemName;
  final String category;
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
  late String _category;
  late String _itemType;
  late String _unit;
  late String _note;

  final UpdateInventory _usecase =
      UpdateInventory(InventoryRepositoryImpl());

  final List<String> _categories = ['冷蔵庫', '冷凍庫', '日用品'];
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
  }

  Future<void> _saveItem() async {
    final item = Inventory(
      id: widget.id,
      itemName: _itemName,
      category: _category,
      itemType: _itemType,
      quantity: 0,
      unit: _unit,
      note: _note,
      createdAt: DateTime.now(),
    );
    await _usecase(item);
  }

  @override
  Widget build(BuildContext context) {
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'カテゴリ'),
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _category = v;
                    final types = _typesMap[v];
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
                items: (_typesMap[_category] ?? ['その他'])
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
