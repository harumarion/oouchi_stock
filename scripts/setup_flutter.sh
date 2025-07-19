#!/bin/bash
# Flutter をインストールしてテストを実行するセットアップスクリプト
# Ubuntu/Debian 環境向けの例です。SDK の取得にはネットワーク接続が必要です。
set -e

# Flutter SDK をダウンロード
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi

# パスを通す
export PATH="$(pwd)/flutter/bin:$PATH"
flutter --version

# 依存パッケージを取得
flutter pub get

# テストを実行
flutter test
