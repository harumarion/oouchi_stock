import 'package:flutter/material.dart';
import '../../domain/entities/price_info.dart';

/// セール詳細情報画面の ViewModel
class PriceDetailViewModel extends ChangeNotifier {
  /// 表示中のセール情報
  PriceInfo info;

  PriceDetailViewModel(this.info);

  /// 編集後の情報で更新し画面に通知
  void updateInfo(PriceInfo newInfo) {
    info = newInfo;
    notifyListeners();
  }
}
