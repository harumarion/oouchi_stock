import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/history_entry.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_data_source.dart';
import '../mappers/inventory_mapper.dart';

/// Firestore実装の在庫リポジトリ
/// 在庫関連画面全体で利用されるデータ取得・更新処理の窓口
class InventoryRepositoryImpl implements InventoryRepository {
  /// Firestoreのリモートデータソース
  final InventoryRemoteDataSource _remoteDataSource;

  /// Firestoreドキュメントとエンティティのマッパー
  final InventoryMapper _mapper;

  /// 依存関係を注入可能なコンストラクタ
  InventoryRepositoryImpl({
    InventoryRemoteDataSource? remoteDataSource,
    InventoryMapper? mapper,
  })  : _remoteDataSource = remoteDataSource ?? const InventoryRemoteDataSource(),
        _mapper = mapper ?? const InventoryMapper();

  @override
  /// カテゴリごとの在庫を監視する
  Stream<List<Inventory>> watchByCategory(String category) {
    return _remoteDataSource
        .watchInventoriesByCategory(category)
        .map((docs) => docs.map(_mapper.fromQueryDocument).toList());
  }

  @override
  /// 全在庫を取得する
  Future<List<Inventory>> fetchAll() async {
    final docs = await _remoteDataSource.fetchAllInventories();
    if (docs.isEmpty) {
      return [];
    }
    return docs.map(_mapper.fromQueryDocument).toList();
  }

  @override
  /// 在庫を追加してIDを返す
  Future<String> addInventory(Inventory inventory) {
    final data = {
      'itemName': inventory.itemName,
      'category': inventory.category,
      'itemType': inventory.itemType,
      'quantity': inventory.quantity,
      'volume': inventory.volume,
      'totalVolume': inventory.totalVolume,
      'unit': inventory.unit,
      'note': inventory.note,
      'monthlyConsumption': inventory.monthlyConsumption,
      'createdAt': Timestamp.fromDate(inventory.createdAt),
    };
    return _remoteDataSource.addInventory(data, inventory.quantity);
  }

  @override
  /// 数量を増減させる
  /// 在庫一覧画面のカードで+/-ボタンを押したときに実行される
  Future<void> updateQuantity(String id, double amount, String type) {
    return _remoteDataSource.updateQuantity(id, amount, type);
  }

  @override
  /// 在庫情報を更新する
  /// 在庫編集画面で保存ボタンを押したときに実行される
  Future<void> updateInventory(Inventory inventory) {
    final updateData = {
      'itemName': inventory.itemName,
      'category': inventory.category,
      'itemType': inventory.itemType,
      'volume': inventory.volume,
      'totalVolume': inventory.totalVolume,
      'unit': inventory.unit,
      'note': inventory.note,
    };
    return _remoteDataSource.updateInventory(inventory.id, updateData);
  }

  @override
  /// 指定IDの在庫情報をストリームで取得する
  /// 在庫詳細画面で表示内容をリアルタイム更新するために利用する
  Stream<Inventory?> watchInventory(String inventoryId) {
    return _remoteDataSource
        .watchInventory(inventoryId)
        .map(_mapper.fromDocument);
  }

  @override
  /// 履歴を監視する
  /// 在庫詳細画面の履歴タブで利用する
  Stream<List<HistoryEntry>> watchHistory(String inventoryId) {
    return _remoteDataSource
        .watchHistory(inventoryId)
        .map((docs) => docs.map(_mapper.fromHistoryDocument).toList());
  }

  @override
  /// 棚卸しを記録する
  /// 在庫詳細画面で棚卸しボタンを押したときに利用する
  Future<void> stocktake(
      String id, double before, double after, double diff) {
    return _remoteDataSource.stocktake(id, before, after, diff);
  }

  @override
  /// 在庫を削除する
  /// 在庫詳細画面で削除操作をしたときに利用する
  Future<void> deleteInventory(String id) {
    return _remoteDataSource.deleteInventory(id);
  }

  @override
  /// 残量が一定以下の在庫を監視する
  /// 買い物リスト画面で残量不足を検知するために利用する
  Stream<List<Inventory>> watchNeedsBuy(double threshold) {
    return _remoteDataSource
        .watchNeedsBuy(threshold)
        .map((docs) => docs.map(_mapper.fromQueryDocument).toList());
  }
}
