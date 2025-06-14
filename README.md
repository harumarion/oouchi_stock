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

## 動作確認

```
flutter run
```

起動後、在庫カードの「+」「-」ボタンをタップすると Firestore の数量が更新されます。
更新内容は Firestore のストリームを通じて自動で反映されるため、画面遷移は不要です。エラーが発生した場合は SnackBar で通知されます。
