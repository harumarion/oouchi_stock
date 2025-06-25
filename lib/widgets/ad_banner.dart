import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// google_mobile_ads 4.0.0 以上で動作する広告表示用ウィジェット
import '../data/repositories/ad_config_repository_impl.dart';
import '../domain/usecases/load_ad_enabled.dart';

/// 画面下部に表示するバナー広告ウィジェット
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  // 読み込んだバナー広告オブジェクト
  BannerAd? _ad;
  // 広告表示が有効かどうかのフラグ
  bool _enabled = true;

  // 広告設定を読み込むユースケース
  final LoadAdEnabled _loadUsecase =
      LoadAdEnabled(AdConfigRepositoryImpl());

  @override
  void initState() {
    super.initState();
    // 画面表示時に広告の読み込みを開始する
    _initAd();
  }

  Future<void> _initAd() async {
    // 広告表示設定を読み込み、無効な場合は処理を中断
    _enabled = await _loadUsecase();
    if (!_enabled) return;
    final banner = BannerAd(
      size: AdSize.banner,
      adUnitId: _adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );
    await banner.load();
    if (mounted) setState(() => _ad = banner);
  }

  // 広告ユニットIDを取得する
  // 実機ではそれぞれのプラットフォーム用テストIDを、
  // それ以外の環境(テストやデスクトップ)では Android 用テストIDを返す
  String get _adUnitId {
    if (Platform.isIOS) {
      // iOS 用テストID
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    // Android またはその他のプラットフォーム
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  @override
  Widget build(BuildContext context) {
    // 設定が無効または広告が読み込めていない場合は空の領域だけ表示
    if (!_enabled || _ad == null) return const SizedBox.shrink();
    // 底部メニューと同じ高さに広告を表示する
    return SizedBox(
      width: double.infinity,
      height: kBottomNavigationBarHeight,
      child: Center(
        child: SizedBox(
          width: _ad!.size.width.toDouble(),
          height: _ad!.size.height.toDouble(),
          child: AdWidget(ad: _ad!),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 読み込んだ広告を解放
    _ad?.dispose();
    super.dispose();
  }
}
