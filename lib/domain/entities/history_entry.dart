class HistoryEntry {
  final String type;
  final double quantity;
  final DateTime timestamp;
  final double before;
  final double after;
  final double diff;

  HistoryEntry(this.type, this.quantity, this.timestamp,
      {this.before = 0, this.after = 0, this.diff = 0});
}
