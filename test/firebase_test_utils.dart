import 'package:flutter/services.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

/// Simple mock setup for Firebase to allow [Firebase.initializeApp] in tests.
Future<void> setupFirebaseCoreMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_core');

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Firebase#initializeCore':
        return [
          {
            'name': defaultFirebaseAppName,
            'options': defaultFirebaseOptions,
          }
        ];
      case 'Firebase#initializeApp':
        return {
          'name': methodCall.arguments['appName'] ?? defaultFirebaseAppName,
          'options': defaultFirebaseOptions,
          'pluginConstants': <String, dynamic>{},
        };
      default:
        return null;
    }
  });
}

const defaultFirebaseOptions = <String, String>{
  'apiKey': 'testApiKey',
  'appId': '1:123:android:123',
  'messagingSenderId': '123',
  'projectId': 'test',
};
