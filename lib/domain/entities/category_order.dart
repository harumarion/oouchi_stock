import 'package:shared_preferences/shared_preferences.dart';
import 'category.dart';

/// カテゴリの並び順を保存・読込するヘルパー
Future<void> saveCategoryOrder(List<Category> list) async {
  final prefs = await SharedPreferences.getInstance();
  final ids = list.map((e) => e.id).toList();
  await prefs.setStringList('category_order', ids.map((e) => e.toString()).toList());
}

/// 保存された並び順を適用する
Future<List<Category>> applyCategoryOrder(List<Category> list) async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getStringList('category_order');
  if (stored == null) return list;
  final order = stored.map(int.parse).toList();
  final map = { for (final c in list) c.id : c };
  final ordered = [ for (final id in order) if (map.containsKey(id)) map[id]! ];
  for (final c in list) {
    if (!order.contains(c.id)) ordered.add(c);
  }
  return ordered;
}
