import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/category.dart';
import 'domain/usecases/update_inventory.dart';
import 'data/repositories/inventory_repository_impl.dart';
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
  Map<String, List<String>> _typesMap = {};
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _typeSub;
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
    _typeSub = FirebaseFirestore.instance
        .collection('itemTypes')
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
        final types = _typesMap[_category.name];
        if (types != null && types.isNotEmpty) {
          _itemType = types.contains(_itemType) ? _itemType : types.first;
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
    _typeSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).inventoryEditTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).inventoryEditTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _itemName,
                decoration: InputDecoration(labelText: AppLocalizations.of(context).itemName),
                onChanged: (v) => _itemName = v,
                validator: (v) =>
                    v == null || v.isEmpty ? AppLocalizations.of(context).itemNameRequired : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Category>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context).category),
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
                decoration: InputDecoration(labelText: AppLocalizations.of(context).itemType),
                value: _itemType,
                items: (_typesMap[_category.name] ?? ['その他'])
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _itemType = v ?? ''),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context).unit),
                value: _unit,
                items:
                    _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (v) => setState(() => _unit = v ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _note,
                decoration: InputDecoration(labelText: AppLocalizations.of(context).memo),
                onChanged: (v) => _note = v,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(AppLocalizations.of(context).save),
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
