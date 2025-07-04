# Contributor Guidelines

- このリポジトリで行うコード変更には、画面名や操作タイミングがわかるよう日本語でコメントを追加してください。
- コミットメッセージは日本語で記述してください。
- ドキュメント (`docs/` 以下) も必要に応じて更新してください。
- テスト (`test/` 以下) を変更に合わせて更新し、`flutter test` が通ることを確認してください。
- クリーンアーキテクチャを採用してください。
- entities ディレクトリ配下では、クラス名やメンバ変数名をコメントしてください。
- repositories ディレクトリ配下では、リポジトリ名とメソッドの役割をコメントしてください。
- services ディレクトリ配下のストラテジー、および util ディレクトリ配下では詳細な処理内容をコメントしてください。
- usecases ディレクトリ配下では、各ユースケースの内容をコメントしてください。
- widgets ディレクトリおよび各 page ファイルでは、画面名とボタンなどのイベント内容をコメントしてください。
- クラスにメンバ変数がある場合は、その名前もコメントに記載してください。
- データが0件、データが空の時に例外が起きないよう必ずチェックを入れること。
- 例外が発生するAPIを利用する際は必ずtry-catchで捕捉し、異常時はログ出力を行い適切に後処理すること。
- Firestore取得失敗時にnullが返る可能性を考慮し、nullチェックを行ってエラー文を表示すること。
- ユーザー入力値にはバリデーションチェックを実装すること。
- 画面表示文は常にローカライズ対応を行うこと。
