import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart'; // ← 自動生成された設定ファイル
import 'domain/entities/category.dart';
import 'notification_service.dart';
import 'home_page.dart';

// アプリのエントリーポイント。Firebase を初期化してから起動する。

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter エンジンの初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase の初期設定
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final loc = await AppLocalizations.delegate.load(locale);
  final notification = NotificationService();
  await notification.init();
  await notification.scheduleWeekly(
    id: 0,
    title: loc.buyListNotificationTitle,
    body: loc.buyListNotificationBody,
  );
  runApp(const MyApp()); // アプリのスタート
}

// アプリのルートウィジェット
class MyApp extends StatefulWidget {
  final List<Category>? initialCategories;
  const MyApp({super.key, this.initialCategories});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null) setState(() => _locale = Locale(code));
  }

  /// アプリ全体の言語設定を更新する
  ///
  /// [locale] 新しく設定するロケール
  Future<void> updateLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // ホーム画面では買い物リストを表示する
      home: HomePage(categories: widget.initialCategories),
    );
  }
}

