import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randomix/screens/home_shell.dart';
import 'package:randomix/strings.dart';

import 'helpers.dart';

void main() {
  testWidgets('shows the four tools and a navigation rail on a wide window', (
    tester,
  ) async {
    setSurface(tester, size: const Size(1100, 900));
    final harness = TestHarness();

    await tester.pumpWidget(harness.wrap(const HomeShell()));
    await tester.pump();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    // Title plus three rail labels is fine; just make sure each tool is named.
    expect(find.text(S.roulette), findsWidgets);
    expect(find.text(S.coin), findsOneWidget);
    expect(find.text(S.dice), findsOneWidget);
    expect(find.text(S.magicBall), findsOneWidget);
  });

  testWidgets('uses a bottom navigation bar on a narrow window', (
    tester,
  ) async {
    setSurface(tester, size: const Size(520, 780));
    final harness = TestHarness();

    await tester.pumpWidget(harness.wrap(const HomeShell()));
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('switching tools updates the title and remembers the page', (
    tester,
  ) async {
    setSurface(tester, size: const Size(1100, 900));
    final harness = TestHarness();

    await tester.pumpWidget(harness.wrap(const HomeShell()));
    await tester.pumpAndSettle();

    await tester.tap(find.text(S.dice));
    await tester.pumpAndSettle();

    expect(harness.settings.lastPage, 'dice');
    // The dice screen is the one that mentions D20.
    expect(find.text('D20'), findsOneWidget);
  });

  testWidgets('restores the last used page', (tester) async {
    setSurface(tester, size: const Size(1100, 900));
    final harness = TestHarness({'last_page': 'magicBall'});

    await tester.pumpWidget(harness.wrap(const HomeShell()));
    await tester.pumpAndSettle();

    expect(find.text(S.shakeBall), findsOneWidget);
  });
}
