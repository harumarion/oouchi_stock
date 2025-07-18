import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

/// 在庫追加・編集フォームで必要となるフィールドをまとめたインターフェース
/// 画面名: 商品登録・編集共通
abstract class InventoryFormViewModel {
  GlobalKey<FormState> get formKey;
  List<Category> get categories;
  Map<String, List<String>> get typesMap;
  Category? get category;
  String get itemName;
  String get itemType;
  double get volume;
  String get unit;
  String get note;
  List<String> get units;

  void setItemName(String v);
  void changeCategory(Category value);
  void changeItemType(String value);
  void setVolume(String value);
  void setUnit(String value);
  void setNote(String value);
}
