/// セール情報を表すデータモデル
class SaleItem {
  /// 商品名
  final String name;
  /// 店舗名
  final String shop;
  /// 通常価格
  final double regularPrice;
  /// セール価格
  final double salePrice;
  /// セール開始日
  final DateTime start;
  /// セール終了日
  final DateTime end;
  /// 在庫数
  final int stock;
  /// おすすめフラグ
  final bool recommended;
  /// 最安値フラグ
  final bool lowest;

  SaleItem({
    required this.name,
    required this.shop,
    required this.regularPrice,
    required this.salePrice,
    required this.start,
    required this.end,
    required this.stock,
    this.recommended = false,
    this.lowest = false,
  });
}
