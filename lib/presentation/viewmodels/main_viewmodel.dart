import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../util/webview_checker.dart';
import '../../firebase_options.dart';
import '../../notification_service.dart';
import '../../i18n/app_localizations.dart';
import '../../domain/factory/dependency_factory.dart';
import '../../domain/usecases/fetch_all_inventory.dart';
import '../../domain/usecases/watch_price_by_type.dart';
import '../../domain/usecases/auto_add_prediction_item.dart';
import '../../domain/usecases/auto_add_buy_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アプリ全体の状態を管理する ViewModel
/// 初期化や言語設定、通信状況の監視を担当する
class MainViewModel extends ChangeNotifier {
  /// DI ファクトリ（アプリ全体の自動処理で利用する依存を集約）
  final DependencyFactory _factory;

  /// 初期化完了フラグ
  bool initialized = false;

  /// ログイン済みフラグ
  bool loggedIn = false;

  /// 現在のロケール
  Locale? locale;

  /// スナックバー表示用キー
  final messengerKey = GlobalKey<ScaffoldMessengerState>();

  StreamSubscription<List<ConnectivityResult>>? _connSub;

  /// 初期化処理を実行
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    try {
      // WebView が利用可能なときのみ広告 SDK を初期化
      // WebView が無効な端末で PacProcessor 例外が出るのを防ぐ
      if (await WebViewChecker.isAvailable()) {
        await MobileAds.instance.initialize();
      } else {
        debugPrint('WebView not available, skip MobileAds initialization');
      }
    } catch (e, s) {
      // 予期せぬ理由で初期化に失敗してもアプリが落ちないようログのみ出力
      debugPrint('MobileAds initialize failed: $e\n$s');
    }
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    FirebaseAuth.instance.setLanguageCode(systemLocale.languageCode);
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _setupNotification();
      await _runAutoPrediction();
      // 起動時に在庫を評価し、必要なら買い物リストへ自動登録
      await _runAutoBuyList();
      loggedIn = true;
    }
    await _loadLocale();
    initialized = true;
    notifyListeners();
  }

  /// 通知設定を行う
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

  MainViewModel({DependencyFactory? factory})
      : _factory = factory ?? DependencyFactory.instance;

  /// 在庫と価格を評価し買い物予報を更新
  // アプリ起動時に在庫を評価して買い物予報を更新する
  Future<void> _runAutoPrediction() async {
    final FetchAllInventory fetchAll =
        _factory.createFetchAllInventory();
    final WatchPriceByType watchPrice =
        _factory.createWatchPriceByType();
    final settings = await _factory.loadPurchaseDecisionSettings();
    final decision = _factory.createPurchaseDecision(
      threshold: 2,
      settings: settings,
    );
    final AutoAddPredictionItem auto =
        _factory.createAutoAddPredictionItem(decision);
    final list = await fetchAll();
    for (final inv in list) {
      final prices = await watchPrice(inv.category, inv.itemType).first;
      final price = prices.isNotEmpty ? prices.first : null;
      await auto(inv, price);
    }
  }

  /// 在庫と価格を評価し買い物リストを更新する
  /// アプリ起動時に在庫を評価して買い物リストへ自動追加を試みる
  Future<void> _runAutoBuyList() async {
    final FetchAllInventory fetchAll =
        _factory.createFetchAllInventory();
    final WatchPriceByType watchPrice =
        _factory.createWatchPriceByType();
    final settings = await _factory.loadPurchaseDecisionSettings();
    final decision = _factory.createPurchaseDecision(
      threshold: 2,
      settings: settings,
    );
    final AutoAddBuyItem auto = _factory.createAutoAddBuyItem(decision);
    final list = await fetchAll();
    for (final inv in list) {
      final prices = await watchPrice(inv.category, inv.itemType).first;
      final price = prices.isNotEmpty ? prices.first : null;
      await auto(inv, price);
    }
  }

  /// 端末設定から保存済みロケールを読み込む
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null) {
      FirebaseAuth.instance.setLanguageCode(code);
      locale = Locale(code);
    }
  }

  /// ログイン完了後の処理を行う
  Future<void> onLoggedIn() async {
    await _setupNotification();
    loggedIn = true;
    notifyListeners();
  }

  /// アプリ全体のロケールを更新
  Future<void> updateLocale(Locale value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', value.languageCode);
    FirebaseAuth.instance.setLanguageCode(value.languageCode);
    locale = value;
    notifyListeners();
  }

  /// 接続状態の監視を開始
  void startConnectivityWatch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connSub = Connectivity().onConnectivityChanged.listen((results) {
        final offline = results.every((r) => r == ConnectivityResult.none);
        final ctx = messengerKey.currentContext;
        if (ctx == null) return;
        final text = offline
            ? AppLocalizations.of(ctx)!.offline
            : AppLocalizations.of(ctx)!.online;
        messengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(text)),
        );
      });
    });
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }
}
