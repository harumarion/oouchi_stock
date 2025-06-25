# 買い物予報

天気予報のように在庫とセール情報をもとに買っておくべき商品を提案するFlutterアプリです。
広告表示には `google_mobile_ads` (>=5.0.0) を利用しています。

ユーザー向けの操作説明は[取扱説明書](docs/user_manual_ja.md)をご覧ください。
開発者向けの設計方針は[アーキテクチャ案](docs/architecture_proposals_ja.md)を参照してください。
主要画面の実装は `lib/home_page.dart` と `lib/inventory_page.dart` に分割されています。ホーム画面では買い物予報を確認できます。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 開発環境の前提

Android ビルドを行う場合は JDK 17 が必要です。`JAVA_HOME` が JDK 17 を指してい
ることを確認してください。

折りたたみ端末などの最新機種に対応するため、AndroidX Window ライブラリを利用しています。
Flutter エンジンと互換性のある `1.1.x` 系を使用しており、`android/app/build.gradle.kts` では `1.1.0` を指定しています。
ビルド時にエラーが発生する場合は `androidx.window:window` が正しいバージョンで取得できているか確認してください。

## Firebase の設定

[FlutterFire CLI](https://firebase.flutter.dev/docs/cli) を使って Firebase プロジェクトを構成します。初回セットアップや設定を変更したい場合は次のコマンドを実行します。

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

この手順により `lib/firebase_options.dart` や `android/app/google-services.json` などの設定ファイルが生成されます。生成されたファイルには API キーやプロジェクト ID が含まれており、アプリはこれらを参照して Firebase に接続します。CI などでファイルを置き換える場合は以下の環境変数を利用できます。

- `FIREBASE_OPTIONS` : `firebase_options.dart` へのパス
- `GOOGLE_APPLICATION_CREDENTIALS` : サービスアカウント認証情報の JSON ファイル

Firebase Authentication を利用する場合は、Firebase コンソールで
匿名認証や Google 認証など必要なログイン方法を有効にしてください。
設定がされていないとログイン時に `CONFIGURATION_NOT_FOUND` エラーが発生します。

## Firestore のインデックス

一部のクエリでは複合インデックスが必要となります。リポジトリには
`firestore.indexes.json` を含めているので、初回セットアップ時に次のコマンドで
デプロイしてください。

```bash
firebase deploy --only firestore:indexes
```

Firestore コンソールから手動で作成しても構いません。

実行時に `FAILED_PRECONDITION: The query requires an index` のエラーが表示された
場合は、インデックスがまだデプロイされていない可能性があります。上記コマンドを
実行するか、表示される URL からインデックスを作成してください。

このエラーは、例えば `inventory` コレクションをカテゴリで絞り込み、`createdAt`
の降順で並び替えるクエリを実行した際に発生します。ログに次のようなメッセージが
出力される場合はインデックス不足が原因です。

```
W/Firestore: Listen for Query(target=Query(inventory where category==<value> order by -createdAt, -__name__)) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index.}
```
`firestore.indexes.json` にはこのクエリに対応したインデックス定義を含めているため、
`firebase deploy --only firestore:indexes` を実行してデプロイすることで解消でき
ます。

同様に、セール情報管理機能で利用する `priceInfos` コレクションをカテゴリや商品種別で
絞り込むクエリでもインデックスが必要です。これらの定義も `firestore.indexes.json`
に含めているので、設定後は同じコマンドでデプロイしてください。

## 実行手順

次のコマンドを順に実行してアプリを起動します。

```bash
flutter pub get       # 依存パッケージを取得
flutter run           # アプリを実行
```

Firebase の設定を変更した場合は `flutterfire configure` を再度実行してください。

## テスト

`test/` ディレクトリにウィジェットテストが含まれています。テストは以下のコマンドで実行できます。

```bash
flutter test
```

テスト前に Firebase の設定ファイルが生成されていることを確認してください。
すべてのウィジェットに対するテストコードを含めています。
## 動作確認

```
flutter run
```

起動後、在庫カードの「+」「-」ボタンをタップすると Firestore の数量が更新されます。
更新内容は Firestore のストリームを通じて自動で反映されるため、画面遷移は不要です。エラーが発生した場合は SnackBar で通知されます。
