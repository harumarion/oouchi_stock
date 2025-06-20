import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/buy_item.dart';
import '../../domain/repositories/buy_list_repository.dart';

class BuyListRepositoryImpl implements BuyListRepository {
  static const _key = 'buy_list_items';
  final StreamController<List<BuyItem>> _controller =
      StreamController<List<BuyItem>>.broadcast();
  bool _initialized = false;

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<void> _init() async {
    if (_initialized) return;
    final prefs = await _prefs;
    final items = prefs.getStringList(_key) ?? [];
    _controller.add(items.map(BuyItem.fromKey).toList());
    _initialized = true;
  }

  @override
  Stream<List<BuyItem>> watchItems() {
    _init();
    return _controller.stream;
  }

  Future<void> _save(List<BuyItem> items) async {
    final prefs = await _prefs;
    await prefs.setStringList(_key, items.map((e) => e.key).toList());
    _controller.add(List.from(items));
  }

  @override
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
  Future<void> removeItem(BuyItem item) async {
    await _init();
    final prefs = await _prefs;
    final list = prefs.getStringList(_key) ?? [];
    list.remove(item.key);
    await prefs.setStringList(_key, list);
    _controller.add(list.map(BuyItem.fromKey).toList());
  }
}
