import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_category_page.dart';
import 'edit_category_page.dart';

/// カテゴリを一覧表示し追加・削除・編集を行う画面。
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
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _sub;
  List<String> _list = [];

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.initial);
    _sub = FirebaseFirestore.instance
        .collection('categories')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _list =
            snapshot.docs.map((d) => d.data()['name'] as String).toList();
      });
      widget.onChanged(List.from(_list));
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
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
      body: ListView(
        children: [
          for (final c in _list)
            ListTile(
              title: Text(c),
              onLongPress: () async {
                final result = await showModalBottomSheet<String>(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('編集'),
                          onTap: () => Navigator.pop(context, 'edit'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('削除'),
                          onTap: () => Navigator.pop(context, 'delete'),
                        ),
                      ],
                    ),
                  ),
                );
                if (result == 'delete') {
                  _deleteCategory(c);
                } else if (result == 'edit') {
                  await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCategoryPage(initialName: c),
                    ),
                  );
                }
              },
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
            // 追加後は Stream が自動で更新される
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
