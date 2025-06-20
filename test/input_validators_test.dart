import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:oouchi_stock/util/input_validators.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('正の数値バリデーション', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));
    expect(positiveNumberValidator(context, '0'), isNotNull);
    expect(positiveNumberValidator(context, '1'), isNull);
  });

  testWidgets('非負数バリデーション', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));
    expect(nonNegativeNumberValidator(context, '-1'), isNotNull);
    expect(nonNegativeNumberValidator(context, '0'), isNull);
  });
}

