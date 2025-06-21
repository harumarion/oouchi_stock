import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/buy_item.dart';
import '../../domain/repositories/buy_list_repository.dart';

/// SharedPreferences を用いて買い物リストを保存するリポジトリ実装
class BuyListRepositoryImpl implements BuyListRepository {
  static const _key = 'buy_list_items';
  final StreamController<List<BuyItem>> _controller =
      StreamController<List<BuyItem>>.broadcast();
  bool _initialized = false;

  /// SharedPreferences の取得
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// 初回のみストレージからリストを読み込む
  Future<void> _init() async {
    if (_initialized) return;
    final prefs = await _prefs;
    final items = prefs.getStringList(_key) ?? [];
    _controller.add(items.map(BuyItem.fromKey).toList());
    _initialized = true;
  }

  @override
  /// 買い物リストの変更を監視する
  Stream<List<BuyItem>> watchItems() {
    _init();
    return _controller.stream;
  }

  @override
  /// アイテムを追加して保存
  Future<void> addItem(BuyItem item) async {
    await _init();
    final prefs = await _prefs;
    final list = prefs.getStringList(_key) ?? [];
    if (!list.contains(item.key)) {
      list.add(item.key);
      await prefs.setStringList(_key, list);
      _controller.add(list.map(BuyItem.fromKey).toList());
    }
  }

  @override
  /// アイテムを削除して保存
  Future<void> removeItem(BuyItem item) async {
    await _init();
    final prefs = await _prefs;
    final list = prefs.getStringList(_key) ?? [];
    list.remove(item.key);
    await prefs.setStringList(_key, list);
    _controller.add(list.map(BuyItem.fromKey).toList());
  }
}
