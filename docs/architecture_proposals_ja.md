# ウィジェット肥大化への対応案

本アプリではクリーンアーキテクチャを採用していますが、画面ごとのウィジェットが大きくなりがちです。一般的なアーキテクチャの考え方に沿った対策案を以下にまとめます。

## 1. ウィジェットの分割
- 画面内のコンポーネントを小さな StatelessWidget / StatefulWidget として切り出し、`lib/widgets` 配下に配置します。
- これによりファイル単位で役割が明確になり、テストもしやすくなります。
- 例として `InventoryCard` を `lib/widgets/inventory_card.dart` へ分離しました。
- 買い物予報画面の `PredictionCard` やセール情報画面の `SaleItemCard` も
- 同様に `lib/widgets` 配下へ切り出しています。
- 同様に `main.dart` にあったホーム画面と在庫画面を
  `lib/home_page.dart` と `lib/inventory_page.dart` に切り出しています。
- 論理処理は可能な限り UseCase として切り出します。例えば
  `HomePage` にあった残り日数計算処理を `CalculateDaysLeft` ユースケースへ移動しました。

## 2. 状態管理の導入
- UI とビジネスロジックを分離するため、Riverpod や BLoC などの状態管理ライブラリを利用します。
- 画面側は状態の監視とイベント通知のみに集中させ、データ取得や加工は ViewModel / Bloc で行います。

## 3. MVVM などのパターン
- Clean Architecture をベースに、プレゼンテーション層では MVVM や Presenter パターンを採用する方法もあります。
- ViewModel が UseCase を呼び出し、画面は ViewModel を監視するだけにすると見通しが良くなります。
- ウィジェットでは UseCase や Repository を直接扱わず、処理はすべて ViewModel 経由で行います。
- 例として `AddInventoryPage` をはじめ、カテゴリの追加・編集画面やセール情報追加画面も
  ViewModel (`AddCategoryViewModel`, `EditCategoryViewModel`, `EditInventoryViewModel` など) で状態管理するようリファクタリングしました。
  さらに在庫一覧画面でも `InventoryPageViewModel` と `InventoryListViewModel` を導入し、
  画面の状態遷移を ViewModel に集約しました。
  買い物予報画面も `BuyListViewModel` を用いてロジックを分離しています。
  また、アプリ起動時の初期化処理は `MainViewModel` にまとめ、
  `main.dart` は ViewModel を利用するだけの形に変更しました。

## 4. ルーティングの整理
- 画面遷移が複雑になった場合は、Navigator 2.0 (Router API) を利用してルーティングを一元管理します。

以上の方法を組み合わせることで、ウィジェットの肥大化を防ぎ、保守性を高めることができます。
