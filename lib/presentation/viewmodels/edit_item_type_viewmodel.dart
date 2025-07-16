// Flutter の基本ウィジェットとステート管理を使用
import 'package:flutter/material.dart';

import '../../domain/entities/item_type.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/update_item_type.dart';
import '../../data/repositories/item_type_repository_impl.dart';

/// 品種編集画面の状態を管理する ViewModel
class EditItemTypeViewModel extends ChangeNotifier {
  /// 品種更新ユースケース
  final UpdateItemType _usecase = UpdateItemType(ItemTypeRepositoryImpl());

  /// フォームキー
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// 編集対象品種
  final ItemType original;

  /// 品種名
  String name;

  /// 選択中のカテゴリ
  Category? category;

  /// 選択可能なカテゴリ一覧
  final List<Category> categories;

  EditItemTypeViewModel(this.original, this.categories)
      : name = original.name {
    if (categories.isNotEmpty) {
      category = categories.firstWhere(
        (c) => c.name == original.category,
        orElse: () => categories.first,
      );
    }
  }

  /// 入力値を保存
  Future<void> save() async {
    final updated = ItemType(
      id: original.id,
      category: category?.name ?? '',
      name: name,
      createdAt: original.createdAt,
    );
    await _usecase(updated);
  }
}
