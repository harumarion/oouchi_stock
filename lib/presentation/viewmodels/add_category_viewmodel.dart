import 'dart:math';
// Flutter の基本ウィジェットとステート管理を使用
import 'package:flutter/material.dart' hide Category;

import '../../domain/entities/category.dart';
import '../../domain/usecases/add_category.dart';
import '../../data/repositories/category_repository_impl.dart';

/// カテゴリ追加画面の状態を管理する ViewModel
class AddCategoryViewModel extends ChangeNotifier {
  /// カテゴリ追加ユースケース
  final AddCategory _usecase = AddCategory(CategoryRepositoryImpl());

  /// フォームキー
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// カテゴリ名
  String name = '';

  /// 選択中のカラー
  Color? color;

  /// 選択候補の色一覧
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.cyan,
  ];

  AddCategoryViewModel();

  /// カテゴリ保存
  Future<void> save() async {
    final category = Category(
      id: Random().nextInt(0xffffffff),
      name: name,
      createdAt: DateTime.now(),
      color: color == null
          ? null
          : '#${color!.value.toRadixString(16).padLeft(8, '0').substring(2)}',
    );
    await _usecase(category);
  }
}
