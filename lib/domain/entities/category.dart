/// 商品カテゴリを表すエンティティ
class Category {
  /// 一意なID
  final int id;

  /// カテゴリ名
  final String name;

  /// 作成日時
  final DateTime createdAt;

  /// 表示色（任意）
  final String? color;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    this.color,
  });
}
