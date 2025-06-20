import 'package:flutter/material.dart';
import 'i18n/app_localizations.dart';
import 'domain/entities/category.dart';

/// カテゴリの並び順を変更する画面
class ReorderCategoriesPage extends StatefulWidget {
  final List<Category> categories;
  const ReorderCategoriesPage({super.key, required this.categories});

  @override
  State<ReorderCategoriesPage> createState() => _ReorderCategoriesPageState();
}

class _ReorderCategoriesPageState extends State<ReorderCategoriesPage> {
  // 画面内で編集中のカテゴリ並び順リスト
  late List<Category> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.categories);
  }

  @override
  Widget build(BuildContext context) {
    // 戻る操作でも現在の並び順を返すため WillPopScope でラップする
    return WillPopScope(
      onWillPop: () async {
        // Android の戻るボタン等で閉じた場合も並び順を保存
        Navigator.pop(context, _list);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.reorder),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, _list),
              child: Text(AppLocalizations.of(context)!.save),
            )
          ],
        ),
        body: ReorderableListView(
          children: [
            for (final c in _list)
              ListTile(key: ValueKey(c.id), title: Text(c.name)),
          ],
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = _list.removeAt(oldIndex);
              _list.insert(newIndex, item);
            });
          },
        ),
      ),
    );
  }
}
