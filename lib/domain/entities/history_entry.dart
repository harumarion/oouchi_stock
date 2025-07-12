/// 在庫履歴の1レコードを表すエンティティ
class HistoryEntry {
  /// 操作種別 (add/used/stocktake など)
  final String type;

  /// 変更した総容量
  final double quantity;

  /// 操作日時
  final DateTime timestamp;

  /// 操作前の総容量
  final double before;

  /// 操作後の総容量
  final double after;

  /// 増減量(総容量)
  final double diff;

  HistoryEntry(this.type, this.quantity, this.timestamp,
      {this.before = 0, this.after = 0, this.diff = 0});
}
