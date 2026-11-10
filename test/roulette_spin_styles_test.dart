import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randomix/core/spin_style.dart';
import 'package:randomix/screens/roulette_screen.dart';
import 'package:randomix/strings.dart';
import 'package:randomix/widgets/result_text.dart';
import 'package:randomix/widgets/spin_visuals.dart';

import 'helpers.dart';

Future<void> _addOption(WidgetTester tester, String value) async {
  final field = find.byType(TextField).first;
  await tester.enterText(field, value);
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
}

String? _result(WidgetTester tester) {
  final finder = find.byKey(const Key('roulette_result'));
  if (finder.evaluate().isEmpty) return null;
  return tester.widget<ResultText>(finder).value;
}

void main() {
  for (final style in RouletteSpinStyle.values) {
    testWidgets('${style.id} spin reveals one of the options', (tester) async {
      setSurface(tester, size: const Size(900, 1200));
      final harness = TestHarness({'spin_style': style.id});

      await tester.pumpWidget(
        harness.wrap(const Scaffold(body: RouletteScreen())),
      );
      await tester.pump();

      await _addOption(tester, 'Alpha');
      await _addOption(tester, 'Beta');

      await tester.tap(find.text(S.spinRoulette));
      await tester.pumpAndSettle();

      expect(['Alpha', 'Beta'], contains(_result(tester)));
    });
  }

  testWidgets('the chosen style comes from the settings', (tester) async {
    setSurface(tester, size: const Size(900, 1200));
    final harness = TestHarness({'spin_style': 'coverflow'});

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: RouletteScreen())),
    );
    await tester.pump();

    await _addOption(tester, 'Alpha');
    await _addOption(tester, 'Beta');

    await tester.tap(find.text(S.spinRoulette));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(CoverFlowSpinView), findsOneWidget);
    expect(find.byType(WheelSpinView), findsNothing);

    await tester.pumpAndSettle();
    expect(_result(tester), isNotNull);
  });

  testWidgets('a full wheel with 30 options still spins', (tester) async {
    setSurface(tester, size: const Size(900, 1400));
    final options = List<String>.generate(30, (i) => 'Choice $i');
    final harness = TestHarness({
      'spin_style': 'wheel',
      'roulette_options': jsonEncode(options),
    });

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: RouletteScreen())),
    );
    await tester.pump();

    await tester.tap(find.text(S.spinRoulette));
    await tester.pumpAndSettle();

    expect(options, contains(_result(tester)));
  });

  testWidgets('inputs are locked while the spin runs', (tester) async {
    setSurface(tester, size: const Size(900, 1200));
    final harness = TestHarness({'spin_style': 'chips'});

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: RouletteScreen())),
    );
    await tester.pump();

    await _addOption(tester, 'Alpha');
    await _addOption(tester, 'Beta');

    await tester.tap(find.text(S.spinRoulette));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.enabled, isFalse);

    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).enabled,
      isTrue,
    );
  });

  testWidgets('the chips race fits the minimum window width', (tester) async {
    setSurface(tester, size: const Size(440, 900));
    final harness = TestHarness({'spin_style': 'chips'});

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: RouletteScreen())),
    );
    await tester.pump();

    await _addOption(tester, 'Alpha');
    await _addOption(tester, 'Beta');

    await tester.tap(find.text(S.spinRoulette));
    await tester.pumpAndSettle();

    expect(['Alpha', 'Beta'], contains(_result(tester)));
  });

  testWidgets('range mode counts numbers and still reveals a value', (
    tester,
  ) async {
    setSurface(tester, size: const Size(900, 1200));
    final harness = TestHarness({'roulette_range_mode': true});

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: RouletteScreen())),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField).at(0), '3');
    await tester.enterText(find.byType(TextField).at(1), '4');
    await tester.pump();

    await tester.tap(find.text(S.spinRoulette));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // During the count-up the result area shows a NumberReel, not the result.
    expect(find.byKey(const Key('roulette_result')), findsNothing);
    expect(find.byType(Text), findsWidgets);

    await tester.pumpAndSettle();
    final value = int.tryParse(_result(tester) ?? '');
    expect(value, isNotNull);
    expect(value, inInclusiveRange(3, 4));
  });
}
