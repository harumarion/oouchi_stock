import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// アプリ共通のテーマを定義するクラス
class AppTheme {
  // アクションに使用するメインカラー
  static const Color primaryColor = Color(0xFF4A90E2);
  // 画面の背景色
  static const Color scaffoldBackgroundColor = Color(0xFFEFF6FD);
  // セール表示に利用する色
  static const Color saleColor = Color(0xFFE65100);
  // 成功や推奨を示す色
  static const Color successColor = Color(0xFF43A047);
  // メインテキストの色
  static const Color textColor = Color(0xFF212121);
  // 補助テキストの色
  static const Color subTextColor = Color(0xFF616161);

  /// ライトテーマの定義
  /// MaterialApp の `theme` に設定され、全画面で利用されます。
  static ThemeData get lightTheme {
    // アプリ全体で使用するテキストスタイルを定義
    // 各画面のウィジェットツリー生成時に参照されます
    final baseTextTheme = TextTheme(
      // 画面タイトルの基本フォント
      // ログイン画面や在庫一覧画面のタイトルに使用
      // ここでは Roboto フォントを利用
      titleLarge: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      // 一般的な本文に使用するフォント
      // すべての画面の説明文や入力フォームに適用される
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      // ボタンやラベルで使用するフォント
      // ユーザー操作時のフィードバックに関わる
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      // 注釈や補足に使用するフォント
      // 詳細画面の備考欄などで利用
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: subTextColor,
      ),
    );

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: successColor,
      onSecondary: Colors.white,
      error: saleColor,
      onError: Colors.white,
      background: scaffoldBackgroundColor,
      onBackground: textColor,
      surface: Colors.white,
      onSurface: textColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle:
            baseTextTheme.titleLarge?.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: baseTextTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: baseTextTheme.labelLarge,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: baseTextTheme.labelLarge,
        ),
      ),
      // ホーム画面や在庫一覧画面で利用するタブバーの配色設定
      // 選択時も非選択時も文字が読みやすいように白系の色を使用
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
    );
  }
}
