import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/ad_config_repository.dart';

/// SharedPreferences を利用した広告設定リポジトリ
class AdConfigRepositoryImpl implements AdConfigRepository {
  static const _key = 'ads_enabled';

  @override
  Future<bool> loadEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true; // 既定では広告表示
  }

  @override
  Future<void> saveEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}
