import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'domain/entities/buy_list_condition_settings.dart';

/// 買うべきリスト条件設定画面
class BuyListConditionSettingsPage extends StatefulWidget {
  const BuyListConditionSettingsPage({super.key});

  @override
  State<BuyListConditionSettingsPage> createState() => _BuyListConditionSettingsPageState();
}

class _BuyListConditionSettingsPageState
    extends State<BuyListConditionSettingsPage> {
  // 現在選択されている条件種別
  BuyListConditionType _type = BuyListConditionType.threshold;
  // しきい値入力用コントローラ
  late TextEditingController _thresholdController;
  // 日数入力用コントローラ
  late TextEditingController _daysController;
  // 入力値を保持する変数
  double _threshold = 0;
  int _days = 7;

  @override
  void initState() {
    super.initState();
    _thresholdController = TextEditingController();
    _daysController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    // 保存済みの条件を取得
    final settings = await loadBuyListConditionSettings();
    setState(() {
      _type = settings.type;
      _threshold = settings.threshold;
      _days = settings.days;
      _thresholdController.text = _threshold.toString();
      _daysController.text = _days.toString();
    });
  }

  Future<void> _save() async {
    // テキストフィールドの内容を変数へ反映
    _threshold = double.tryParse(_thresholdController.text) ?? _threshold;
    _days = int.tryParse(_daysController.text) ?? _days;
    await saveBuyListConditionSettings(
      BuyListConditionSettings(type: _type, threshold: _threshold, days: _days),
    );
  }

  @override
  void dispose() {
    // コントローラを破棄してメモリリークを防ぐ
    _thresholdController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // 画面描画。しきい値や日数を入力し、保存ボタンで設定を更新する
    return Scaffold(
      appBar: AppBar(title: Text(loc.buyListConditionSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RadioListTile<BuyListConditionType>(
            value: BuyListConditionType.threshold,
            groupValue: _type,
            title: Text(loc.thresholdCondition),
            onChanged: (v) => setState(() => _type = v!),
          ),
          TextField(
            decoration: InputDecoration(labelText: loc.thresholdLabel),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: _thresholdController,
            onChanged: (v) => _threshold = double.tryParse(v) ?? _threshold,
          ),
          RadioListTile<BuyListConditionType>(
            value: BuyListConditionType.days,
            groupValue: _type,
            title: Text(loc.daysCondition),
            onChanged: (v) => setState(() => _type = v!),
          ),
          TextField(
            decoration: InputDecoration(labelText: loc.daysLabel),
            keyboardType: TextInputType.number,
            controller: _daysController,
            onChanged: (v) => _days = int.tryParse(v) ?? _days,
          ),
          RadioListTile<BuyListConditionType>(
            value: BuyListConditionType.or,
            groupValue: _type,
            title: Text(loc.orCondition),
            onChanged: (v) => setState(() => _type = v!),
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
