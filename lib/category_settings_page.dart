import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'util/firestore_refs.dart';
import 'util/date_time_parser.dart';
import 'edit_category_page.dart';
import 'domain/entities/category.dart';
import 'domain/entities/category_order.dart';
import 'domain/usecases/add_category.dart';
import 'data/repositories/category_repository_impl.dart';

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

  /// カテゴリ追加ユースケース
  final AddCategory _addUsecase = AddCategory(CategoryRepositoryImpl());

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

  /// カラーピッカーで色を変更
  Future<void> _changeColor(Category category) async {
    final loc = AppLocalizations.of(context)!;
    final baseColor = category.color == null
        ? Colors.blue
        : Color(int.parse('ff${category.color!.replaceFirst('#', '')}', radix: 16));
    final result = await showColorPickerDialog(
      context,
      baseColor,
      title: Text(loc.selectColor),
      showColorCode: true,
    );
    if (result == null) return;

    try {
      final snapshot = await userCollection('categories')
          .where('id', isEqualTo: category.id)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.update({
          'color': '#${result.value.toRadixString(16).padLeft(8, '0').substring(2)}',
        });
      }
    } catch (e) {
      debugPrint('色更新失敗: $e');
    }
  }

  /// ダイアログからカテゴリを即時追加
  Future<void> _addCategoryDialog() async {
    final controller = TextEditingController();
    final loc = AppLocalizations.of(context)!;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.addCategory),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: loc.categoryName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(loc.ok),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    final category = Category(
      id: Random().nextInt(0xffffffff),
      name: name,
      createdAt: DateTime.now(),
      color: null,
    );
    await _addUsecase(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.categorySettingsTitle)),
      body: ReorderableListView(
        buildDefaultDragHandles: false,
        children: [
          for (var i = 0; i < _list.length; i++)
            Dismissible(
              key: ValueKey(_list[i].id),
              direction: DismissDirection.startToEnd,
              confirmDismiss: (_) async {
                final loc = AppLocalizations.of(context)!;
                final res = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: Text(loc.deleteConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(loc.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(loc.delete),
                      ),
                    ],
                  ),
                );
                return res ?? false;
              },
              // スワイプでカテゴリを削除する
              onDismissed: (_) {
                final c = _list[i];
                setState(() {
                  // 画面上から即座に削除するためリストから対象を除外
                  _list.remove(c);
                });
                _deleteCategory(c);
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Builder(builder: (context) {
                final c = _list[i];
                return ListTile(
                  leading: GestureDetector(
                    onTap: () => _changeColor(c),
                    child: c.color == null
                        ? const Icon(Icons.color_lens)
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
                  ),
                  title: Text(c.name),
                  trailing: ReorderableDragStartListener(
                    index: i,
                    child: const Icon(Icons.drag_handle),
                  ),
                  // カテゴリをタップしたときに編集画面へ遷移
                  onTap: () async {
                    await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditCategoryPage(category: c),
                      ),
                    );
                  },
                );
              }),
            ),
        ],
        onReorder: (oldIndex, newIndex) async {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = _list.removeAt(oldIndex);
            _list.insert(newIndex, item);
          });
          await saveCategoryOrder(_list);
          widget.onChanged(List.from(_list));
        },
      ),
      floatingActionButton: FloatingActionButton(
        // カテゴリ設定画面専用のヒーロータグ
        heroTag: 'categoryFab',
        // 追加ボタン押下時に名前入力ダイアログを表示
        onPressed: _addCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
