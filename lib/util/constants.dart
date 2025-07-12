// アプリ全体で使用する固定文字列を定義
// Firestore上のデータは日本語表記で保存しているため、その値を定数化しておく

/// 品種が未設定の場合に使用するデフォルト値
const String itemTypeOther = 'その他';

/// 容量単位の候補リスト
const List<String> defaultUnits = ['個', '本', '袋', 'ロール', 'リットル'];
