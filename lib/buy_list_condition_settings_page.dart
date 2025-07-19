import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'domain/entities/buy_list_condition_settings.dart';
import 'widgets/number_text_form_field.dart';

/// 買い物予報条件設定画面
/// 設定画面から遷移し、予報に使用するしきい値や日数を入力する
class BuyListConditionSettingsPage extends StatefulWidget {
  const BuyListConditionSettingsPage({super.key});

  @override
  State<BuyListConditionSettingsPage> createState() => _BuyListConditionSettingsPageState();
}

class _BuyListConditionSettingsPageState
    extends State<BuyListConditionSettingsPage> {
  // 現在選択されている条件種別
  BuyListConditionType _type = BuyListConditionType.threshold;
  // 入力値を保持する変数
  double _threshold = 0;
  int _days = 7;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // 保存済みの条件を取得
    final settings = await loadBuyListConditionSettings();
    if (!mounted) return;
    setState(() {
      _type = settings.type;
      _threshold = settings.threshold;
      _days = settings.days;
    });
  }

  // 保存ボタンを押したときに実行される処理
  Future<void> _save() async {
    await saveBuyListConditionSettings(
      BuyListConditionSettings(type: _type, threshold: _threshold, days: _days),
    );
  }

  @override
  void dispose() {
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
          NumberTextFormField(
            label: loc.thresholdLabel,
            initial: _threshold.toString(),
            onChanged: (v) => _threshold = double.tryParse(v) ?? _threshold,
          ),
          RadioListTile<BuyListConditionType>(
            value: BuyListConditionType.days,
            groupValue: _type,
            title: Text(loc.daysCondition),
            onChanged: (v) => setState(() => _type = v!),
          ),
          NumberTextFormField(
            label: loc.daysLabel,
            initial: _days.toString(),
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
            // 保存ボタンが押されたときの処理
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
