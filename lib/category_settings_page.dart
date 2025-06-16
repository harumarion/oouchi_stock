import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_category_page.dart';

/// カテゴリを一覧表示し並び替えや追加・削除を行う画面。
class CategorySettingsPage extends StatefulWidget {
  final List<String> initial;
  final ValueChanged<List<String>> onChanged;
  const CategorySettingsPage({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<CategorySettingsPage> createState() => _CategorySettingsPageState();
}

class _CategorySettingsPageState extends State<CategorySettingsPage> {
  late List<String> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.initial);
  }

  Future<void> _deleteCategory(String name) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('name', isEqualTo: name)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      if (mounted) {
        setState(() => _list.remove(name));
        widget.onChanged(List.from(_list));
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('削除しました')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('削除に失敗しました')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリ設定')),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = _list.removeAt(oldIndex);
            _list.insert(newIndex, item);
          });
          widget.onChanged(List.from(_list));
        },
        children: [
          for (final c in _list)
            ListTile(
              key: ValueKey(c),
              title: Text(c),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text('「$c」を削除しますか？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('削除'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    _deleteCategory(c);
                  }
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCategory = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoryPage()),
          );
          if (newCategory != null) {
            setState(() => _list.add(newCategory));
            widget.onChanged(List.from(_list));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
