import 'package:flutter/material.dart';

/// スプラッシュ画面
/// アプリ起動時の初期化中に表示される。アプリアイコンとローディングインジケータを
/// 画面中央に配置するシンプルな画面。
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アプリアイコン画像を表示
            // アイコンは web/icons/Icon-512.png を利用
            Image.asset('web/icons/Icon-512.png', width: 128, height: 128),
            const SizedBox(height: 24),
            // 初期化中を示すインジケータ
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
