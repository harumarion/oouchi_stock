import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_refs.dart';
import 'util/date_time_parser.dart';

import 'domain/entities/item_type.dart';
import 'domain/entities/category.dart';
import 'add_item_type_page.dart';
import 'edit_item_type_page.dart';
import 'default_item_types.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

// 品種設定画面。カテゴリ別にタブで品種を一覧表示する
class ItemTypeSettingsPage extends StatefulWidget {
  /// 設定画面から渡されるカテゴリ一覧
  final List<Category> categories;
  const ItemTypeSettingsPage({super.key, required this.categories});

  @override
  State<ItemTypeSettingsPage> createState() => _ItemTypeSettingsPageState();
}

class _ItemTypeSettingsPageState extends State<ItemTypeSettingsPage> {
  /// Firestore 監視用のサブスクリプション
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _sub;
  /// 取得した品種リスト
  List<ItemType> _list = [];

  @override
  void initState() {
    super.initState();
    // Firestore の itemTypes コレクションを監視し一覧を更新
    _sub = userCollection('itemTypes')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        // データが無ければデフォルト品種を登録
        await insertDefaultItemTypes();
        return;
      }
      setState(() {
        _list = snapshot.docs.map((d) {
          final data = d.data();
          return ItemType(
            id: data['id'] ?? 0,
            category: data['category'] ?? '',
            name: data['name'] ?? '',
            createdAt: parseDateTime(data['createdAt']),
          );
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    // 画面破棄時にストリーム購読を解除
    _sub.cancel();
    super.dispose();
  }

  Future<void> _delete(ItemType item) async {
    // 品種を削除する
    try {
      final snapshot = await userCollection('itemTypes')
          .where('id', isEqualTo: item.id)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      if (mounted) {
        // 削除成功を通知
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.deleted)),
        );
      }
    } catch (e) {
      // 例外内容をログに出力
      debugPrint('品種削除失敗: $e');
      if (mounted) {
        // 削除失敗を通知
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.deleteFailed)),
        );
      }
    }
  }

  /// 指定カテゴリの品種一覧を表示するリスト
  Widget _buildList(String category) {
    final items = _list.where((e) => e.category == category).toList();
    return ListView(
      children: [
        for (final t in items)
          ListTile(
            title: Text(t.name),
            onLongPress: () async {
              final result = await showModalBottomSheet<String>(
                context: context,
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title:
                            Text(AppLocalizations.of(context)!.itemTypeEditTitle),
                        onTap: () => Navigator.pop(context, 'edit'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: Text(AppLocalizations.of(context)!.delete),
                        onTap: () => Navigator.pop(context, 'delete'),
                      ),
                    ],
                  ),
                ),
              );
              if (result == 'delete') {
                _delete(t);
              } else if (result == 'edit') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditItemTypePage(
                      itemType: t,
                      categories: widget.categories,
                    ),
                  ),
                );
              }
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // カテゴリが存在しない場合は登録を促す画面を表示
    if (widget.categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.itemTypeSettingsTitle)),
        body: Center(child: Text(AppLocalizations.of(context)!.addCategory)),
      );
    }
    return DefaultTabController(
      // カテゴリ数だけタブを生成
      length: widget.categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.itemTypeSettingsTitle),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final c in widget.categories)
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Tab(text: c.name),
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final c in widget.categories) _buildList(c.name),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddItemTypePage(categories: widget.categories),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
