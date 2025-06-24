import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'domain/entities/category.dart';
import 'login_page.dart';
import 'root_navigation_page.dart';
import 'theme.dart';
import 'presentation/viewmodels/main_viewmodel.dart';

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
  /// 画面全体の状態を保持する ViewModel
  late final MainViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MainViewModel()
      ..addListener(() {
        if (mounted) setState(() {});
      })
      ..init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_viewModel.initialized) {
      // 初期化中はローディング画面を表示
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    if (!_viewModel.loggedIn) {
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
        // 共通のテーマ設定を適用
        theme: AppTheme.lightTheme,
        home: LoginPage(onLoggedIn: () async {
          await _viewModel.onLoggedIn();
        }),
      );
    }
    return MyApp(viewModel: _viewModel);
  }
}

// アプリのルートウィジェット
class MyApp extends StatefulWidget {
  final List<Category>? initialCategories;
  final MainViewModel viewModel;
  const MyApp({super.key, this.initialCategories, required this.viewModel});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late final MainViewModel _viewModel;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
    _listener = () {
      if (mounted) setState(() {});
    };
    _viewModel.addListener(_listener);
    _viewModel.startConnectivityWatch();
  }

  Future<void> updateLocale(Locale locale) async {
    await _viewModel.updateLocale(locale);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _viewModel.messengerKey,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _viewModel.locale,
      // 共通のテーマ設定を適用
      theme: AppTheme.lightTheme,
      // 画面下部のメニューで各機能へ移動できる RootNavigationPage を表示
      home: const RootNavigationPage(),
    );
  }
}

