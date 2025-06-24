import 'package:flutter/material.dart';
import '../../data/repositories/price_repository_impl.dart';
import '../../domain/entities/price_info.dart';
import '../../domain/usecases/delete_price_info.dart';
import '../../domain/usecases/watch_price_by_type.dart';

/// セール情報履歴画面の状態を管理する ViewModel
class PriceHistoryViewModel {
  final String category;
  final String itemType;
  final WatchPriceByType watch;
  final DeletePriceInfo deleter;

  PriceHistoryViewModel({
    required this.category,
    required this.itemType,
    WatchPriceByType? watch,
    DeletePriceInfo? deleter,
  })  : watch = watch ?? WatchPriceByType(PriceRepositoryImpl()),
        deleter = deleter ?? DeletePriceInfo(PriceRepositoryImpl());

  /// セール情報ストリーム
  Stream<List<PriceInfo>> stream() => watch(category, itemType);

  /// 指定 ID を削除
  Future<void> delete(String id) => deleter(id);
}
