import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:randomix/core/presets.dart';
import 'package:randomix/core/roulette_logic.dart';

void main() {
  group('normalize', () {
    test('trims and collapses whitespace', () {
      expect(RouletteLogic.normalize('  a   b \t c '), 'a b c');
      expect(RouletteLogic.normalize('plain'), 'plain');
      expect(RouletteLogic.normalize('   ').isEmpty, isTrue);
    });
  });

  group('tryAdd', () {
    test('adds a normalized option', () {
      final options = <String>[];
      final result = RouletteLogic.tryAdd(
        options,
        '  Hello   world ',
        allowEquals: false,
      );
      expect(result, OptionAddResult.added);
      expect(options, ['Hello world']);
    });

    test('ignores empty input', () {
      final options = <String>[];
      expect(
        RouletteLogic.tryAdd(options, '   ', allowEquals: false),
        OptionAddResult.empty,
      );
      expect(options, isEmpty);
    });

    test('rejects duplicates unless allowed', () {
      final options = ['A'];
      expect(
        RouletteLogic.tryAdd(options, 'A', allowEquals: false),
        OptionAddResult.duplicate,
      );
      expect(options, ['A']);

      expect(
        RouletteLogic.tryAdd(options, 'A', allowEquals: true),
        OptionAddResult.added,
      );
      expect(options, ['A', 'A']);
    });

    test('caps the list at 30 options', () {
      final options = List<String>.generate(30, (i) => 'o$i');
      expect(
        RouletteLogic.tryAdd(options, 'extra', allowEquals: false),
        OptionAddResult.full,
      );
      expect(options.length, 30);
      expect(options, isNot(contains('extra')));
    });

    test('thirty options are allowed', () {
      final options = List<String>.generate(29, (i) => 'o$i');
      expect(
        RouletteLogic.tryAdd(options, 'last', allowEquals: false),
        OptionAddResult.added,
      );
      expect(options.length, 30);
    });
  });

  group('parseRange', () {
    test('accepts increasing ranges', () {
      final range = RouletteLogic.parseRange('1', '10');
      expect(range, isNotNull);
      expect(range!.min, 1);
      expect(range.max, 10);
    });

    test('accepts negative bounds', () {
      final range = RouletteLogic.parseRange('-5', '5');
      expect(range!.min, -5);
      expect(range.max, 5);
    });

    test('rejects equal, reversed, empty and non numeric ranges', () {
      expect(RouletteLogic.parseRange('5', '5'), isNull);
      expect(RouletteLogic.parseRange('10', '1'), isNull);
      expect(RouletteLogic.parseRange('', '10'), isNull);
      expect(RouletteLogic.parseRange('a', 'b'), isNull);
      expect(RouletteLogic.parseRange('1.5', '3'), isNull);
    });

    test('trims the fields', () {
      expect(RouletteLogic.parseRange(' 1 ', ' 2 ')!.min, 1);
    });
  });

  group('picking', () {
    test('numbers stay inside the inclusive range', () {
      for (var i = 0; i < 500; i++) {
        final value = RouletteLogic.pickNumber(_random(1), min: 3, max: 3 + 1);
        expect(value, inInclusiveRange(3, 4));
      }
      final ranged = RouletteLogic.pickNumber(_random(2), min: -2, max: 2);
      expect(ranged, inInclusiveRange(-2, 2));
    });

    test('handles large spans without 32 bit overflow', () {
      final value = RouletteLogic.pickNumber(
        _random(3),
        min: 0,
        max: 3000000000,
      );
      expect(value, inInclusiveRange(0, 3000000000));
    });

    test('returns a member of the option list', () {
      final options = ['a', 'b', 'c'];
      for (var i = 0; i < 50; i++) {
        expect(
          options,
          contains(RouletteLogic.pickOption(options, _random(i))),
        );
      }
    });

    test('generic options are Option1..3', () {
      expect(RouletteLogic.genericOptions(), ['Option1', 'Option2', 'Option3']);
    });
  });

  group('presets', () {
    test('letters are the 26 uppercase letters', () {
      expect(Presets.letters.length, 26);
      expect(Presets.letters.first, 'A');
      expect(Presets.letters.last, 'Z');
    });

    test('numbers are 1 to 100', () {
      expect(Presets.numbers.length, 100);
      expect(Presets.numbers.first, '1');
      expect(Presets.numbers.last, '100');
    });

    test('cards are 52, suit major, value first', () {
      final cards = Presets.cards;
      expect(cards.length, 52);
      expect(cards.first, 'A♠');
      expect(cards.last, 'K♣');
      expect(cards, contains('10♥'));
      expect(cards.toSet().length, 52);
    });
  });
}

_SeededRandom _random(int seed) => _SeededRandom(seed);

/// Deterministic stand-in so the range tests do not depend on dart:math
/// internals while still exercising the bounds.
class _SeededRandom implements Random {
  _SeededRandom(this.seed);

  final int seed;
  int _calls = 0;

  @override
  int nextInt(int max) {
    _calls++;
    return (seed * 31 + _calls * 17) % max;
  }

  @override
  double nextDouble() => nextInt(1000) / 1000;

  @override
  bool nextBool() => nextInt(2) == 0;
}
