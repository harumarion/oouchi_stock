import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/buy_item.dart';
import '../../domain/repositories/buy_list_repository.dart';

/// SharedPreferences を用いて買い物リストを保存するリポジトリ実装
/// アプリ全体で同一インスタンスを共有するシングルトンとして実装する
class BuyListRepositoryImpl implements BuyListRepository {
  BuyListRepositoryImpl._internal();
  static final BuyListRepositoryImpl _instance = BuyListRepositoryImpl._internal();

  /// インスタンス取得
  factory BuyListRepositoryImpl() => _instance;

  /// テスト用に状態をリセットする
  static void resetForTest() {
    _instance._initialized = false;
    _instance._items = [];
    _instance._ignoredIds = [];
  }
  // SharedPreferences に保存する際のキー
  static const _key = 'buy_list_items';
  // 手動削除した在庫IDを保持するキー
  static const _ignoreKey = 'buy_list_ignore';
  // リスト更新通知用のストリームコントローラ
  final StreamController<List<BuyItem>> _controller =
      StreamController<List<BuyItem>>.broadcast();
  // 初期化済みかどうか
  bool _initialized = false;
  // 現在の買い物リストを保持する
  List<BuyItem> _items = [];
  // 手動削除した在庫ID一覧
  List<String> _ignoredIds = [];

  /// SharedPreferences の取得
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// 初回のみストレージからリストを読み込む
  Future<void> _init() async {
    if (_initialized) return;
    final prefs = await _prefs;
    final items = prefs.getStringList(_key) ?? [];
    final ignored = prefs.getStringList(_ignoreKey) ?? [];
    _items = items.map(BuyItem.fromKey).toList();
    _ignoredIds = List<String>.from(ignored);
    _initialized = true;
  }

  @override
  /// 買い物リストの変更を監視する
  Stream<List<BuyItem>> watchItems() async* {
    await _init();
    yield List<BuyItem>.from(_items);
    yield* _controller.stream;
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
      _items = list.map(BuyItem.fromKey).toList();
      _controller.add(List<BuyItem>.from(_items));
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
    _items = list.map(BuyItem.fromKey).toList();
    _controller.add(List<BuyItem>.from(_items));
  }

  @override
  /// 手動削除した在庫IDを記録
  Future<void> addIgnoredId(String id) async {
    await _init();
    if (_ignoredIds.contains(id)) return;
    _ignoredIds.add(id);
    final prefs = await _prefs;
    await prefs.setStringList(_ignoreKey, _ignoredIds);
  }

  @override
  /// 削除記録を解除
  Future<void> removeIgnoredId(String id) async {
    await _init();
    if (_ignoredIds.remove(id)) {
      final prefs = await _prefs;
      await prefs.setStringList(_ignoreKey, _ignoredIds);
    }
  }

  @override
  /// 記録されている削除済み在庫ID一覧を取得
  Future<List<String>> loadIgnoredIds() async {
    await _init();
    return List<String>.from(_ignoredIds);
  }

  @override
  /// 在庫IDに紐づくアイテムを削除
  Future<void> removeItemsByInventoryId(String inventoryId) async {
    await _init();
    final prefs = await _prefs;
    final list = prefs.getStringList(_key) ?? [];
    list.removeWhere((key) {
      final parts = key.split('|');
      return parts.length >= 3 && parts[2] == inventoryId;
    });
    await prefs.setStringList(_key, list);
    _items = list.map(BuyItem.fromKey).toList();
    await removeIgnoredId(inventoryId);
    _controller.add(List<BuyItem>.from(_items));
  }
}
