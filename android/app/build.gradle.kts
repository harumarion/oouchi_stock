plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.oouchi_stock"
    compileSdk = flutter.compileSdkVersion
    // Override Flutter's default NDK version to satisfy Firebase libraries
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Java 17 を利用する設定。Flutter 3.13 以降の推奨バージョンに合わせています
        // この設定は Android ビルド時に使用され、ホーム画面や在庫画面など
        // すべての画面をビルドする際に適用されます
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications などの依存ライブラリが利用する
        // Java 8 以降の API を下位 API レベルでも利用できるよう desugaring を有効化
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Kotlin コンパイルターゲットも JDK 17 に合わせる
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.oouchi_stock"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Ensure ProviderInstaller is available at runtime
    implementation("com.google.android.gms:play-services-base:18.4.0")
    // 折りたたみ端末などのウィンドウ情報取得に必要なライブラリ
    // FlutterView が WindowInfoTracker を利用する際に参照され、
    // 画面が表示されるタイミングでロードされる
    // Flutter エンジンが想定している Window ライブラリのバージョンに合わせる
    // 画面が表示されるときに折りたたみ端末の情報を取得するために利用
    // Flutter エンジンが期待する古い Sidecar API へ対応するため
    // バージョン 1.0.0 を指定して SidecarInterface の欠落エラーを回避
    implementation("androidx.window:window:1.0.0")
    // 折りたたみ端末向けサイドカー API のクラスが読み込めず
    // NoClassDefFoundError が発生することへの対策として sidecar 依存も追加
    // ログイン画面やホーム画面を表示する際に FlutterView が参照する
    // 現在入手可能な最新のサイドカー API ライブラリは 0.1.0 のため
    // 1.1.0 では取得に失敗しビルドエラーとなるためバージョンを修正
    implementation("androidx.window:window-sidecar:0.1.0")
    // Desugaring library required when using Java 8+ APIs on lower API levels
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
