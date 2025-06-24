import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// カテゴリを新規追加するユースケース
class AddCategory {
  /// データ保存先リポジトリ
  final CategoryRepository repository;

  AddCategory(this.repository);

  /// カテゴリを保存する
  Future<void> call(Category category) async {
    await repository.addCategory(category);
  }
}
