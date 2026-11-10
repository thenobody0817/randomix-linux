/// Dice rules, ported from the Android `UniversalDiceFragment`.
library;

import 'dart:math';

enum DiceType {
  d4(4),
  d6(6),
  d8(8),
  d10(10),
  d12(12),
  d20(20);

  const DiceType(this.sides);

  final int sides;

  String get label => 'D$sides';

  static DiceType fromName(String? name) => DiceType.values.firstWhere(
    (t) => t.name == name,
    orElse: () => DiceType.d6,
  );
}

/// Upstream stores "3 vs 3" as dice count 0.
const int threeVsThreeCount = 0;
const int maxDiceCount = 10;

class DiceRoll {
  const DiceRoll({
    required this.type,
    required this.values,
    this.team1 = 0,
    this.team2 = 0,
  });

  final DiceType type;
  final List<int> values;

  /// Sums of the two teams; zero outside of 3 vs 3.
  final int team1;
  final int team2;

  bool get isThreeVsThree =>
      values.length == 6 && type == DiceType.d6 && team2 > 0;

  int get sum => values.fold(0, (a, b) => a + b);

  /// The text after "The result is:".
  String get display => isThreeVsThree ? '$team1 — $team2' : '$sum';
}

class DiceRoller {
  const DiceRoller._();

  /// Rolls one die of [type].
  static int rollOne(DiceType type, Random random) =>
      random.nextInt(type.sides) + 1;

  /// Rolls [count] dice. `count == 0` means the 3 vs 3 mode, which always uses
  /// six D6 and compares the sums of the first and last three dice.
  static DiceRoll roll({
    required DiceType type,
    required int count,
    Random? random,
  }) {
    final rnd = random ?? Random();

    if (count == threeVsThreeCount) {
      final values = List<int>.generate(6, (_) => rollOne(DiceType.d6, rnd));
      return DiceRoll(
        type: DiceType.d6,
        values: values,
        team1: values[0] + values[1] + values[2],
        team2: values[3] + values[4] + values[5],
      );
    }

    final clamped = count.clamp(1, maxDiceCount);
    final values = List<int>.generate(clamped, (_) => rollOne(type, rnd));
    return DiceRoll(type: type, values: values);
  }

  /// The pip die is only used when a single D6 is thrown.
  static bool usesPips({required DiceType type, required int count}) =>
      type == DiceType.d6 && count == 1;
}
