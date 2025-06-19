import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'i18n/app_localizations.dart';

/// ログイン画面。匿名ログインと Google ログインを選択できる
///
/// アプリ起動直後に表示され、ユーザーがどの方法でログインするか
/// 選択するための画面。
class LoginPage extends StatelessWidget {
  /// ログイン完了後に呼び出されるコールバック
  final VoidCallback onLoggedIn;

  const LoginPage({super.key, required this.onLoggedIn});

  /// Google ログインボタンを押したときの処理
  ///
  /// ログイン画面で「Googleでログイン」を選択すると実行される
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      if (user != null && user.isAnonymous) {
        await user.linkWithCredential(credential);
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      onLoggedIn();
    } on FirebaseAuthException catch (e) {
      // 認証エラーの詳細を表示して原因特定を容易にする
      final msg = '${AppLocalizations.of(context)!.saveFailed}: '
          '${e.message ?? e.code}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  /// 「匿名で続行」ボタンを押したときの処理
  ///
  /// Firebase の設定が不完全な場合は [FirebaseAuthException] が
  /// 投げられるため、ここで捕捉してエラーメッセージを表示する
  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      onLoggedIn();
    } on FirebaseAuthException catch (e) {
      // Firebase の設定不足や Play サービスの問題などで失敗した場合
      final msg = '${AppLocalizations.of(context)!.saveFailed}: '
          '${e.message ?? e.code}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  /// ログイン画面の UI を構築する
  ///
  /// 匿名ログイン・Google ログインの2つのボタンを中央に配置
  Widget build(BuildContext context) {
    // ローカライズデータが読み込まれる前はローディングを表示
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(loc.loginTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _signInAnonymously(context),
              child: Text(loc.anonymousLogin),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _signInWithGoogle(context),
              child: Text(loc.signInWithGoogle),
            ),
          ],
        ),
      ),
    );
  }
}
