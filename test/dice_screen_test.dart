import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randomix/screens/dice_screen.dart';
import 'package:randomix/strings.dart';

import 'helpers.dart';

void main() {
  testWidgets('throws dice and shows the labelled result', (tester) async {
    setSurface(tester, size: const Size(900, 1100));
    final harness = TestHarness();

    await tester.pumpWidget(harness.wrap(const Scaffold(body: DiceScreen())));
    await tester.pump();

    await tester.tap(find.text(S.throwDice));
    await tester.pumpAndSettle();

    expect(find.textContaining(S.genericResult), findsOneWidget);
  });

  testWidgets('3 vs 3 shows two team sums', (tester) async {
    setSurface(tester, size: const Size(900, 1100));
    final harness = TestHarness();

    await tester.pumpWidget(harness.wrap(const Scaffold(body: DiceScreen())));
    await tester.pump();

    await tester.tap(find.text(S.threeVThree));
    await tester.pump();

    await tester.tap(find.text(S.throwDice));
    await tester.pumpAndSettle();

    expect(find.textContaining('—'), findsOneWidget);
  });

  testWidgets('remembers the dice type and count', (tester) async {
    setSurface(tester, size: const Size(900, 1100));
    final harness = TestHarness();

    await tester.pumpWidget(harness.wrap(const Scaffold(body: DiceScreen())));
    await tester.pump();

    await tester.tap(find.text('D20'));
    await tester.pump();
    await tester.tap(find.text('4'));
    await tester.pump();

    expect(harness.store.getString('ud_dice_type'), 'd20');
    expect(harness.store.getInt('ud_dice_count'), 4);
  });

  testWidgets('the type selector is disabled in 3 vs 3', (tester) async {
    setSurface(tester, size: const Size(900, 1100));
    final harness = TestHarness();

    await tester.pumpWidget(harness.wrap(const Scaffold(body: DiceScreen())));
    await tester.pump();

    await tester.tap(find.text(S.threeVThree));
    await tester.pump();

    final chip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'D20'),
    );
    expect(chip.onSelected, isNull);
  });
}
