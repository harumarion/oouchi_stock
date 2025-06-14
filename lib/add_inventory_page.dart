import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

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

  final List<String> _categories = ['冷蔵庫', '冷凍庫', '日用品'];
  final List<String> _units = ['個', '本', '袋', 'ロール'];

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
              TextFormField(
                decoration: const InputDecoration(labelText: '商品名'),
                onChanged: (value) => _itemName = value,
                validator: (value) =>
                    value == null || value.isEmpty ? '商品名は必須です' : null,
              ),
              const SizedBox(height: 12),
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
                      if (_quantity > 1) _quantity--;
                    }),
                  ),
                  Text('$_quantity'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '単位'),
                value: _unit,
                items: _units
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (value) => setState(() => _unit = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'メモ（任意）'),
                onChanged: (value) => _note = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('保存'),
                onPressed: () async {
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
