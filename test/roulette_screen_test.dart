import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randomix/screens/roulette_screen.dart';
import 'package:randomix/strings.dart';

import 'helpers.dart';

void main() {
  testWidgets('refuses to spin with fewer than two options', (tester) async {
    setSurface(tester, size: const Size(900, 1000));
    final harness = TestHarness();

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: RouletteScreen())),
    );
    await tester.pump();

    await tester.tap(find.text(S.spinRoulette));
    await tester.pump();
    await tester.pump();

    expect(find.text(S.noEntryRoulette), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('adds options, rejects duplicates and persists them', (
    tester,
  ) async {
    setSurface(tester, size: const Size(900, 1000));
    final harness = TestHarness();

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: RouletteScreen())),
    );
    await tester.pump();

    final field = find.byType(TextField).first;

    await tester.enterText(field, '  Hello   world ');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.enterText(field, 'Second');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.byType(InputChip), findsNWidgets(2));
    expect(find.text('Hello world'), findsOneWidget);
    expect(
      harness.store.getString('roulette_options'),
      contains('Hello world'),
    );

    // A duplicate is rejected with a message and does not add a chip.
    await tester.enterText(field, 'Hello world');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.byType(InputChip), findsNWidgets(2));
    expect(find.text(S.duplicateOption), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('range mode spins a number inside the bounds', (tester) async {
    setSurface(tester, size: const Size(900, 1000));
    final harness = TestHarness();

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: RouletteScreen())),
    );
    await tester.pump();

    await tester.tap(find.text(S.range));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '3');
    await tester.enterText(fields.at(1), '4');
    await tester.pump();

    await tester.tap(find.text(S.spinRoulette));
    await tester.pumpAndSettle();

    final numbers = tester
        .widgetList<Text>(find.byType(Text))
        .map((w) => w.data)
        .whereType<String>()
        .where((t) => int.tryParse(t) != null)
        .toList();
    expect(numbers, isNotEmpty);
    expect(int.parse(numbers.first), inInclusiveRange(3, 4));
  });

  testWidgets('an invalid range shows the upstream warning', (tester) async {
    setSurface(tester, size: const Size(900, 1000));
    final harness = TestHarness();

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: RouletteScreen())),
    );
    await tester.pump();

    await tester.tap(find.text(S.range));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '9');
    await tester.enterText(fields.at(1), '1');
    await tester.pump();

    await tester.tap(find.text(S.spinRoulette));
    await tester.pump();
    await tester.pump();

    expect(find.text(S.wrongRange), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('long press on an empty list adds the generic options', (
    tester,
  ) async {
    setSurface(tester, size: const Size(900, 1000));
    final harness = TestHarness();

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: RouletteScreen())),
    );
    await tester.pump();

    await tester.longPress(find.text(S.spinRoulette));
    await tester.pump();

    expect(find.text('Option1'), findsOneWidget);
    expect(find.text('Option3'), findsOneWidget);
    expect(find.byType(InputChip), findsNWidgets(3));
  });

  testWidgets('remove last chosen drops the winning chip', (tester) async {
    setSurface(tester, size: const Size(900, 1000));
    final harness = TestHarness({'remove_last': true});

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: RouletteScreen())),
    );
    await tester.pump();

    final field = find.byType(TextField).first;
    await tester.enterText(field, 'A');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.enterText(field, 'B');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.byType(InputChip), findsNWidgets(2));

    await tester.tap(find.text(S.spinRoulette));
    await tester.pumpAndSettle();

    expect(find.byType(InputChip), findsOneWidget);
  });

  testWidgets('a spin remembers the option set as a recent entry', (
    tester,
  ) async {
    setSurface(tester, size: const Size(900, 1000));
    final harness = TestHarness();

    await tester.pumpWidget(
      harness.wrap(const Scaffold(body: RouletteScreen())),
    );
    await tester.pump();

    final field = find.byType(TextField).first;
    await tester.enterText(field, 'A');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.enterText(field, 'B');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    await tester.tap(find.text(S.spinRoulette));
    await tester.pumpAndSettle();

    expect(harness.store.getString('recent'), isNotNull);
    expect(harness.store.getString('recent'), contains('A'));
  });
}
