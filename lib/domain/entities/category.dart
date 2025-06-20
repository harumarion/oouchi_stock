class Category {
  final int id;
  final String name;
  final DateTime createdAt;
  final String? color;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    this.color,
  });
}
