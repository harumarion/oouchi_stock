import 'dart:async';
import 'package:flutter/material.dart';
import 'presentation/viewmodels/item_type_settings_viewmodel.dart';
import 'domain/entities/item_type.dart';
import 'domain/entities/category.dart';
import 'add_item_type_page.dart';
import 'edit_item_type_page.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

/// 品種設定画面。カテゴリ別にタブで品種を一覧表示する
class ItemTypeSettingsPage extends StatefulWidget {
  final List<Category> categories;
  const ItemTypeSettingsPage({super.key, required this.categories});

  @override
  State<ItemTypeSettingsPage> createState() => _ItemTypeSettingsPageState();
}

class _ItemTypeSettingsPageState extends State<ItemTypeSettingsPage> {
  late final ItemTypeSettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ItemTypeSettingsViewModel()
      ..addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _delete(ItemType item) async {
    try {
      await _viewModel.delete(item);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.deleted)),
        );
      }
    } catch (e) {
      debugPrint('品種削除失敗: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.deleteFailed)),
        );
      }
    }
  }

  Widget _buildList(String category) {
    final items = _viewModel.list.where((e) => e.category == category).toList();
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
                        title: Text(AppLocalizations.of(context)!.itemTypeEditTitle),
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
    if (widget.categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.itemTypeSettingsTitle)),
        body: Center(child: Text(AppLocalizations.of(context)!.addCategory)),
      );
    }
    return DefaultTabController(
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
                )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final c in widget.categories) _buildList(c.name),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'itemTypeFab',
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
