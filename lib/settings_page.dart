import 'package:flutter/material.dart';
import 'add_category_page.dart';

class SettingsPage extends StatelessWidget {
  final List<String> categories;
  final ValueChanged<List<String>> onReorder;
  const SettingsPage({
    super.key,
    required this.categories,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('カテゴリ追加'),
            onTap: () async {
              final newCategory = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => const AddCategoryPage()),
              );
              if (newCategory != null) {
                final updated = List<String>.from(categories)..add(newCategory);
                onReorder(updated);
              }
            },
          ),
          ListTile(
            title: const Text('カテゴリ並び替え'),
            onTap: () async {
              final result = await Navigator.push<List<String>>(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryOrderPage(initial: categories),
                ),
              );
              if (result != null) onReorder(result);
            },
          ),
        ],
      ),
    );
  }
}

class CategoryOrderPage extends StatefulWidget {
  final List<String> initial;
  const CategoryOrderPage({super.key, required this.initial});

  @override
  State<CategoryOrderPage> createState() => _CategoryOrderPageState();
}

class _CategoryOrderPageState extends State<CategoryOrderPage> {
  late List<String> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリ並び替え')),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = _list.removeAt(oldIndex);
            _list.insert(newIndex, item);
          });
        },
        children: [
          for (final c in _list)
            ListTile(key: ValueKey(c), title: Text(c)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context, _list),
        child: const Icon(Icons.save),
      ),
    );
  }
}
