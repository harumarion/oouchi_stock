// Flutter の基本ウィジェットとステート管理を使用
import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';
import '../../domain/usecases/update_category.dart';
import '../../data/repositories/category_repository_impl.dart';

/// カテゴリ編集画面の状態を管理する ViewModel
class EditCategoryViewModel extends ChangeNotifier {
  /// カテゴリ更新ユースケース
  final UpdateCategory _usecase = UpdateCategory(CategoryRepositoryImpl());

  /// フォームキー
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// 編集対象カテゴリ
  final Category original;

  /// カテゴリ名
  String name;

  EditCategoryViewModel(this.original)
      : name = original.name;

  /// 入力値を保存
  Future<void> save() async {
    final updated = Category(
      id: original.id,
      name: name,
      createdAt: original.createdAt,
      // 色は編集不可のため元の値を保持
      color: original.color,
    );
    await _usecase(updated);
  }
}
