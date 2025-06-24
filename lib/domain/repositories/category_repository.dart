import "../entities/category.dart";
/// Firestore上のカテゴリデータを扱うリポジトリ
abstract class CategoryRepository {
  /// カテゴリを追加してIDを返す
  Future<String> addCategory(Category category);

  /// 既存カテゴリを更新する
  Future<void> updateCategory(Category category);
}
