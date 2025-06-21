import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_refs.dart';
import 'util/date_time_parser.dart';
import 'add_category_page.dart';
import 'edit_category_page.dart';
import 'reorder_categories_page.dart';
import 'domain/entities/category.dart';
import 'domain/entities/category_order.dart';

/// カテゴリを一覧表示し追加・削除・編集を行う画面。
class CategorySettingsPage extends StatefulWidget {
  final List<Category> initial;
  final ValueChanged<List<Category>> onChanged;
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
  List<Category> _list = [];

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.initial);
    _sub = userCollection('categories')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) async {
      var list = snapshot.docs.map((d) {
        final data = d.data();
        return Category(
          id: data['id'] ?? 0,
          name: data['name'] ?? '',
          createdAt: parseDateTime(data['createdAt']),
          color: data['color'],
        );
      }).toList();
      list = await applyCategoryOrder(list);
      setState(() {
        _list = list;
      });
      await saveCategoryOrder(list);
      widget.onChanged(List.from(list));
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  /// 削除ボタンの処理
  Future<void> _deleteCategory(Category category) async {
    try {
      final snapshot = await userCollection('categories')
          .where('id', isEqualTo: category.id)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.deleted)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.deleteFailed)));
      }
    }
  }

  /// 並び順変更画面を開き、結果を保存する
  Future<void> _openReorder() async {
    final result = await Navigator.push<List<Category>>(
      context,
      MaterialPageRoute(
        builder: (_) => ReorderCategoriesPage(categories: _list),
      ),
    );
    if (result != null) {
      await saveCategoryOrder(result);
      setState(() => _list = result);
      widget.onChanged(List.from(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.categorySettingsTitle)),
      body: ListView(
        children: [
          for (final c in _list)
            ListTile(
              leading: c.color == null
                  ? null
                  : Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(
                            'ff${c.color!.replaceFirst('#', '')}',
                            radix: 16,
                          ),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
              title: Text(c.name),
              onLongPress: () async {
                final result = await showModalBottomSheet<String>(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(AppLocalizations.of(context)!.categoryEditTitle),
                          onTap: () => Navigator.pop(context, 'edit'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: Text(AppLocalizations.of(context)!.delete),
                          onTap: () => Navigator.pop(context, 'delete'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.swap_vert),
                          title: Text(AppLocalizations.of(context)!.reorder),
                          onTap: () => Navigator.pop(context, 'reorder'),
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
                      builder: (_) => EditCategoryPage(category: c),
                    ),
                  );
                } else if (result == 'reorder') {
                  await _openReorder();
                }
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // カテゴリ設定画面専用のヒーロータグ
        heroTag: 'categoryFab',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoryPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
