import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randomix/core/magic_ball_model.dart';
import 'package:randomix/screens/magic_ball_screen.dart';
import 'package:randomix/strings.dart';

import 'helpers.dart';

void main() {
  testWidgets('shakes the ball and answers from the default pool', (
    tester,
  ) async {
    setSurface(tester, size: const Size(900, 1000));
    final harness = TestHarness();

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: MagicBallScreen())),
    );
    await tester.pump();

    await tester.tap(find.text(S.shakeBall));
    await tester.pumpAndSettle();

    final answers = MagicBallModel.defaultAnswers;
    final hasAnswer = answers.any((a) => find.text(a).evaluate().isNotEmpty);
    expect(hasAnswer, isTrue);
  });

  testWidgets('custom answers editor stores the values', (tester) async {
    setSurface(tester, size: const Size(900, 1200));
    final harness = TestHarness();

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: MagicBallScreen())),
    );
    await tester.pump();

    await tester.tap(find.text(S.customAnswers));
    await tester.pumpAndSettle();

    final field = find.byType(TextField).first;
    await tester.enterText(field, 'yes; no; maybe');
    await tester.pump();

    await tester.tap(find.text(S.save));
    await tester.pumpAndSettle();

    expect(harness.settings.customAnswers, 'yes; no; maybe');
    expect(harness.store.getString('custom_answers'), 'yes; no; maybe');
  });

  testWidgets('custom answers replace the pool when active', (tester) async {
    setSurface(tester, size: const Size(900, 1000));
    final harness = TestHarness({
      'custom_answers': 'definitely; absolutely not',
      'custom_answers_active': true,
    });

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: MagicBallScreen())),
    );
    await tester.pump();

    await tester.tap(find.text(S.shakeBall));
    await tester.pumpAndSettle();

    final custom =
        find.text('definitely').evaluate().isNotEmpty ||
        find.text('absolutely not').evaluate().isNotEmpty;
    expect(custom, isTrue);
  });
}
