import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randomix/screens/coin_screen.dart';
import 'package:randomix/strings.dart';

import 'helpers.dart';

void main() {
  testWidgets('flips and shows heads or tails', (tester) async {
    setSurface(tester, size: const Size(900, 1000));
    final harness = TestHarness();

    await tester.pumpWidget(harness.wrap(const Scaffold(body: CoinScreen())));
    await tester.pump();

    expect(find.text(S.resultPlaceholder), findsOneWidget);

    await tester.tap(find.text(S.flipCoin));
    await tester.pumpAndSettle();

    final heads = find.text(S.resultHead).evaluate().isNotEmpty;
    final tails = find.text(S.resultTail).evaluate().isNotEmpty;
    expect(heads || tails, isTrue);
  });

  testWidgets('blocks a second flip during the cooldown', (tester) async {
    setSurface(tester, size: const Size(900, 1000));
    final harness = TestHarness();

    await tester.pumpWidget(harness.wrap(const Scaffold(body: CoinScreen())));
    await tester.pump();

    await tester.tap(find.text(S.flipCoin));
    await tester.pump(const Duration(milliseconds: 1600));
    // Let the flip's completion continuation arm the cooldown timer.
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text(S.flipCoin),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    final after = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text(S.flipCoin),
        matching: find.byType(FilledButton),
      ),
    );
    expect(after.onPressed, isNotNull);
  });
}
