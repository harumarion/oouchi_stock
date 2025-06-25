import 'dart:io';
import 'package:flutter/services.dart';

/// WebView の利用可否を判定するヘルパー
/// 広告 SDK 初期化前に呼び出し、PacProcessor 例外を回避する
class WebViewChecker {
  static const _channel = MethodChannel('com.example.oouchi_stock/webview');
  static bool? _mockResult;

  /// テスト用: 結果を上書きする
  static void setMockResult(bool? result) {
    _mockResult = result;
  }

  /// WebView が利用可能なら true を返す
  static Future<bool> isAvailable() async {
    if (_mockResult != null) return _mockResult!;
    if (!Platform.isAndroid) return true;
    try {
      final result = await _channel.invokeMethod<bool>('isWebViewAvailable');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
