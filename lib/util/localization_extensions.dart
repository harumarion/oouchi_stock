import '../i18n/app_localizations.dart';

/// セール情報画面専用のローカライズ拡張
extension SaleLocExt on AppLocalizations {
  /// セール期間表示用
  String salePeriod(String period) => '期間: $period';
  /// 在庫数表示用
  String stockInfo(int count) => '在庫 $count個';
  /// 買い物リスト追加ボタンのラベル
  String addToList() => '買い物リストに追加';
  /// セール画面タイトル
  String saleListTitle() => '買い得リスト';
  /// セール通知ラベル
  String saleNotify() => 'セール通知';
  /// 終了日順ソートラベル
  String sortEndDate() => '終了日が近い順';
  /// 割引率順ソートラベル
  String sortDiscount() => '割引率順';
  /// おすすめ順ソートラベル
  String sortRecommend() => 'おすすめ順';
}
