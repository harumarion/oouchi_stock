import 'package:flutter/material.dart';
import 'models/inventory_item.dart';

class AddInventoryPage extends StatefulWidget {
  const AddInventoryPage({super.key});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  final _formKey = GlobalKey<FormState>();
  String _itemName = '';
  String _category = '日用品';
  int _quantity = 1;
  String _unit = '個';
  String _note = '';

  final List<String> _categories = ['冷蔵庫', '冷凍庫', '日用品'];
  final List<String> _units = ['個', '本', '袋', 'ロール'];

  Widget _buildItemNameField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '商品名'),
      onChanged: (value) => _itemName = value,
      validator: (value) => value == null || value.isEmpty ? '商品名は必須です' : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'カテゴリ'),
      value: _category,
      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (value) => setState(() => _category = value!),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text('数量:'),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => setState(() {
            if (_quantity > 1) _quantity--;
          }),
        ),
        Text('$_quantity'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => _quantity++),
        ),
      ],
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: '単位'),
      value: _unit,
      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
      onChanged: (value) => setState(() => _unit = value!),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'メモ（任意）'),
      onChanged: (value) => _note = value,
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.save),
      label: const Text('保存'),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          final item = InventoryItem(
            itemName: _itemName,
            category: _category,
            quantity: _quantity,
            unit: _unit,
            note: _note,
          );
          // TODO: 登録処理（FireStoreや状態管理と連携）
          // ignore: avoid_print
          print('Save: ${item.itemName}');
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('在庫を追加')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildItemNameField(),
              const SizedBox(height: 12),
              _buildCategoryDropdown(),
              const SizedBox(height: 12),
              _buildQuantitySelector(),
              const SizedBox(height: 12),
              _buildUnitDropdown(),
              const SizedBox(height: 12),
              _buildNoteField(),
              const SizedBox(height: 24),
              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
