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
  BannerAd? _ad;
  bool _enabled = true;

  final LoadAdEnabled _loadUsecase =
      LoadAdEnabled(AdConfigRepositoryImpl());

  @override
  void initState() {
    super.initState();
    _initAd();
  }

  Future<void> _initAd() async {
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

  String get _adUnitId {
    if (Platform.isAndroid) {
      // Android 用テストID
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // iOS 用テストID
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Unsupported platform');
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled || _ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }
}
