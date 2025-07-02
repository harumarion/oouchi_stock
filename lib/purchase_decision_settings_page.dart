import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'domain/entities/purchase_decision_settings.dart';

/// 購入判定のしきい値を編集する画面
/// 設定画面から遷移し、残り日数と値引き率を入力して保存する
class PurchaseDecisionSettingsPage extends StatefulWidget {
  const PurchaseDecisionSettingsPage({super.key});

  @override
  State<PurchaseDecisionSettingsPage> createState() =>
      _PurchaseDecisionSettingsPageState();
}

class _PurchaseDecisionSettingsPageState
    extends State<PurchaseDecisionSettingsPage> {
  // 慎重判定日数入力コントローラ
  late TextEditingController _cautiousController;
  // 買い時日数入力コントローラ
  late TextEditingController _bestController;
  // 値引き率入力コントローラ
  late TextEditingController _percentController;

  int _cautious = 3;
  int _best = 3;
  double _percent = 10;

  @override
  void initState() {
    super.initState();
    _cautiousController = TextEditingController();
    _bestController = TextEditingController();
    _percentController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    // 保存済み設定の読み込み
    final s = await loadPurchaseDecisionSettings();
    setState(() {
      _cautious = s.cautiousDays;
      _best = s.bestTimeDays;
      _percent = s.discountPercent;
      _cautiousController.text = _cautious.toString();
      _bestController.text = _best.toString();
      _percentController.text = _percent.toString();
    });
  }

  Future<void> _save() async {
    // 入力値を設定として保存
    _cautious = int.tryParse(_cautiousController.text) ?? _cautious;
    _best = int.tryParse(_bestController.text) ?? _best;
    _percent = double.tryParse(_percentController.text) ?? _percent;
    await savePurchaseDecisionSettings(PurchaseDecisionSettings(
      cautiousDays: _cautious,
      bestTimeDays: _best,
      discountPercent: _percent,
    ));
  }

  @override
  void dispose() {
    _cautiousController.dispose();
    _bestController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // 画面構築。数値を入力して保存ボタンで戻る
    return Scaffold(
      appBar: AppBar(title: Text(loc.purchaseDecisionSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration:
                InputDecoration(labelText: loc.cautiousDaysLabel),
            keyboardType: TextInputType.number,
            controller: _cautiousController,
          ),
          TextField(
            decoration: InputDecoration(labelText: loc.bestDaysLabel),
            keyboardType: TextInputType.number,
            controller: _bestController,
          ),
          TextField(
            decoration: InputDecoration(labelText: loc.discountPercentLabel),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            controller: _percentController,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await _save();
              if (mounted) Navigator.pop(context, true);
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }
}
