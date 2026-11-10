import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:randomix/core/dice_roller.dart';

void main() {
  group('DiceType', () {
    test('covers the six upstream dice', () {
      expect(DiceType.values.map((t) => t.sides), [4, 6, 8, 10, 12, 20]);
      expect(DiceType.values.map((t) => t.label), [
        'D4',
        'D6',
        'D8',
        'D10',
        'D12',
        'D20',
      ]);
    });

    test('fromName falls back to D6', () {
      expect(DiceType.fromName('d20'), DiceType.d20);
      expect(DiceType.fromName('nonsense'), DiceType.d6);
      expect(DiceType.fromName(null), DiceType.d6);
    });
  });

  group('roll', () {
    test('values respect each die range', () {
      for (final type in DiceType.values) {
        final roll = DiceRoller.roll(type: type, count: 10, random: Random(7));
        expect(roll.values.length, 10);
        for (final value in roll.values) {
          expect(value, inInclusiveRange(1, type.sides));
        }
      }
    });

    test('sums the dice', () {
      final roll = DiceRoller.roll(
        type: DiceType.d6,
        count: 3,
        random: Random(1),
      );
      expect(roll.sum, roll.values.reduce((a, b) => a + b));
      expect(roll.display, '${roll.sum}');
      expect(roll.isThreeVsThree, isFalse);
    });

    test('clamps the count between 1 and 10', () {
      expect(
        DiceRoller.roll(
          type: DiceType.d6,
          count: 25,
          random: Random(2),
        ).values.length,
        10,
      );
      expect(
        DiceRoller.roll(
          type: DiceType.d6,
          count: -4,
          random: Random(2),
        ).values.length,
        1,
      );
    });

    test('three versus three rolls six D6 and compares team sums', () {
      final roll = DiceRoller.roll(
        type: DiceType.d20,
        count: threeVsThreeCount,
        random: Random(4),
      );
      expect(roll.type, DiceType.d6);
      expect(roll.values.length, 6);
      for (final value in roll.values) {
        expect(value, inInclusiveRange(1, 6));
      }
      expect(roll.team1, roll.values.take(3).reduce((a, b) => a + b));
      expect(roll.team2, roll.values.skip(3).reduce((a, b) => a + b));
      expect(roll.isThreeVsThree, isTrue);
      expect(roll.display, '${roll.team1} — ${roll.team2}');
    });

    test('single die rolls are independent', () {
      final values = <int>{};
      for (var i = 0; i < 60; i++) {
        values.add(DiceRoller.rollOne(DiceType.d6, Random(i)));
      }
      expect(values, containsAll([1, 2, 3, 4, 5, 6]));
    });
  });

  group('pip mode', () {
    test('only a single D6 shows pips', () {
      expect(DiceRoller.usesPips(type: DiceType.d6, count: 1), isTrue);
      expect(DiceRoller.usesPips(type: DiceType.d8, count: 1), isFalse);
      expect(DiceRoller.usesPips(type: DiceType.d6, count: 2), isFalse);
      expect(DiceRoller.usesPips(type: DiceType.d6, count: 0), isFalse);
    });
  });
}
