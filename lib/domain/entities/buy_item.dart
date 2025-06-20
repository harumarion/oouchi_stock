class BuyItem {
  final String name;
  final String category;
  const BuyItem(this.name, this.category);

  String get key => '$category|$name';

  static BuyItem fromKey(String key) {
    final idx = key.indexOf('|');
    if (idx == -1) return BuyItem(key, '');
    return BuyItem(key.substring(idx + 1), key.substring(0, idx));
  }
}
