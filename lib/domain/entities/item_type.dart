/// 品種（商品種別）を表すエンティティ
class ItemType {
  /// 一意なID
  final int id;

  /// 所属するカテゴリ名
  final String category;

  /// 品種名
  final String name;

  /// 作成日時
  final DateTime createdAt;

  ItemType({
    required this.id,
    required this.category,
    required this.name,
    required this.createdAt,
  });
}
