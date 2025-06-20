package com.example.oouchi_stock

import android.content.Intent
import android.os.Bundle
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.security.ProviderInstaller
import io.flutter.embedding.android.FlutterActivity

/// アプリ起動時に最初に表示される画面をホストする Activity
/// 各 Flutter 画面 (ホーム、在庫一覧など) はここから生成される

class MainActivity : FlutterActivity(), ProviderInstaller.ProviderInstallListener {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // アプリ起動直後に呼ばれ、ホーム画面などの Flutter 画面を表示する前に
        // Google Play 開発者サービスのセキュリティプロバイダーを確認する
        // 一部のエミュレーターには Play services が含まれていないため
        // ProviderInstaller 呼び出し前にチェックしないと SecurityException が発生する
        val availability = GoogleApiAvailability.getInstance()
        val result = availability.isGooglePlayServicesAvailable(this)
        if (result == ConnectionResult.SUCCESS) {
            ProviderInstaller.installIfNeededAsync(this, this)
        } else if (availability.isUserResolvableError(result)) {
            availability.showErrorDialogFragment(this, result, 0)
        }
    }

    override fun onProviderInstalled() {
        // Security provider successfully installed. Nothing to do.
    }

    override fun onProviderInstallFailed(errorCode: Int, intent: Intent?) {
        // If Google Play services is missing or needs to be updated, display a dialog.
        val availability = GoogleApiAvailability.getInstance()
        if (availability.isUserResolvableError(errorCode)) {
            availability.showErrorDialogFragment(this, errorCode, 0)
        }
    }
}
