import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// カテゴリを更新するユースケース
class UpdateCategory {
  /// 利用するリポジトリ
  final CategoryRepository repository;

  UpdateCategory(this.repository);

  /// カテゴリを更新
  Future<void> call(Category category) async {
    await repository.updateCategory(category);
  }
}
