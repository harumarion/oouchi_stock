# oouchi_stock

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase の設定

Firebase を利用するために [FlutterFire CLI](https://firebase.flutter.dev/docs/cli) で
プロジェクトを構成します。初回セットアップや設定を変更したい場合は以下の手順を
実行してください。

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

上記を実行すると `lib/firebase_options.dart` と
`android/app/google-services.json` などの設定ファイルが生成されます。生成されたファ
イルには API キーやプロジェクト ID が含まれており、アプリはこれらを参照して
Firebase に接続します。CI などでファイルを置き換える場合は次の環境変数を利用する
こともできます。

- `FIREBASE_OPTIONS` : `firebase_options.dart` へのパスを指定
- `GOOGLE_APPLICATION_CREDENTIALS` : サービスアカウント認証情報の JSON ファイル

## 実行手順

以下のコマンドを順に実行することでアプリを起動できます。

```bash
flutter pub get       # 依存パッケージを取得
flutter run           # アプリを実行
```

Firebase 設定を変更した場合は `flutterfire configure` を再度実行してください。

## テスト

`test/` ディレクトリにウィジェットテストが含まれています。テストを実行するには次
のコマンドを利用します。

```bash
flutter test
```

テスト実行前に Firebase の設定ファイルが生成されていることを確認してください。
