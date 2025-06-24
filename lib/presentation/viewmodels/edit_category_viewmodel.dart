// Flutter の基本ウィジェットとステート管理を使用
import 'package:flutter/material.dart' hide Category;

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

  /// 選択中のカラー
  Color? color;

  /// 選択候補の色一覧
  final List<Color> colors = const [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.cyan,
  ];

  EditCategoryViewModel(this.original)
      : name = original.name,
        color = original.color != null
            ? Color(0xFF000000 | int.parse(original.color!.substring(1), radix: 16))
            : null;

  /// 入力値を保存
  Future<void> save() async {
    final updated = Category(
      id: original.id,
      name: name,
      createdAt: original.createdAt,
      color: color == null
          ? null
          : '#${color!.value.toRadixString(16).padLeft(8, '0').substring(2)}',
    );
    await _usecase(updated);
  }
}
