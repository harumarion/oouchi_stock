import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart'; // ← 自動生成された設定ファイル
import 'domain/entities/category.dart';
import 'notification_service.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'root_navigation_page.dart';

// アプリのエントリーポイント。初期化処理中はローディング画面を表示する。

void main() {
  runApp(const AppLoader());
}

/// Firebase や通知の初期設定を行い、完了次第 MyApp を表示するウィジェット
class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  bool _initialized = false;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    WidgetsFlutterBinding.ensureInitialized(); // Flutter エンジンの初期化
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ); // Firebase の初期設定
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _setupNotification();
      _loggedIn = true;
    }
    setState(() => _initialized = true);
  }

  Future<void> _setupNotification() async {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final loc = await AppLocalizations.delegate.load(locale);
    final notification = NotificationService();
    await notification.init();
    await notification.scheduleWeekly(
      id: 0,
      title: loc.buyListNotificationTitle,
      body: loc.buyListNotificationBody,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      // 初期化中はローディング画面を表示
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    if (!_loggedIn) {
      // 未ログインならログイン画面を表示
      return MaterialApp(
        // アプリ名などのローカライズに必要なデリゲートを設定
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: LoginPage(onLoggedIn: () async {
          await _setupNotification();
          setState(() => _loggedIn = true);
        }),
      );
    }
    return const MyApp();
  }
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
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  // 接続状態の変化を監視するためのストリーム購読
  // 全画面共通で利用し、通信状況が変わるたびにスナックバーで通知する
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    // 接続状態が変わった際にオンライン/オフラインのメッセージを表示
    // onConnectivityChanged は複数の接続結果を返すようになったため
    // すべて none であればオフラインと判断する
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      final offline =
          results.every((r) => r == ConnectivityResult.none);
      final text = offline
          ? AppLocalizations.of(context)!.offline
          : AppLocalizations.of(context)!.online;
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(text)),
      );
    });
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
  void dispose() {
    // ストリーム購読を解除してリソースを解放
    _connSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messengerKey,
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
      // 画面下部のメニューで各機能へ移動できる RootNavigationPage を表示
      home: const RootNavigationPage(),
    );
  }
}

