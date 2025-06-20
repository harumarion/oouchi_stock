import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// アプリ共通のテーマを定義するクラス
class AppTheme {
  // アクションに使用するメインカラー
  static const Color primaryColor = Color(0xFF4A90E2);
  // 画面の背景色
  static const Color scaffoldBackgroundColor = Color(0xFFF5F5F5);
  // セール表示に利用する色
  static const Color saleColor = Color(0xFFD0021B);
  // 成功や推奨を示す色
  static const Color successColor = Color(0xFF7ED321);
  // メインテキストの色
  static const Color textColor = Color(0xFF333333);
  // 補助テキストの色
  static const Color subTextColor = Color(0xFF888888);

  /// ライトテーマの定義
  static ThemeData get lightTheme {
    // アプリ全体で使用するテキストスタイルを定義
    // 画面読み込み時に ThemeData として読み込まれます
    final baseTextTheme = TextTheme(
      titleLarge: GoogleFonts.notoSansJP(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.notoSansJP(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      labelLarge: GoogleFonts.notoSansJP(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodySmall: GoogleFonts.notoSansJP(
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
    );
  }
}
