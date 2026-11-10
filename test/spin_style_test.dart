import 'package:flutter_test/flutter_test.dart';
import 'package:randomix/core/spin_style.dart';

void main() {
  test('all three styles are available with their ids', () {
    expect(RouletteSpinStyle.values.map((s) => s.id), [
      'wheel',
      'coverflow',
      'chips',
    ]);
  });

  test('fromId falls back to the wheel', () {
    expect(RouletteSpinStyle.fromId('chips'), RouletteSpinStyle.chips);
    expect(RouletteSpinStyle.fromId('coverflow'), RouletteSpinStyle.coverflow);
    expect(RouletteSpinStyle.fromId('nope'), RouletteSpinStyle.wheel);
    expect(RouletteSpinStyle.fromId(null), RouletteSpinStyle.wheel);
  });

  test('every style has a sensible duration', () {
    for (final style in RouletteSpinStyle.values) {
      expect(style.duration.inMilliseconds, greaterThanOrEqualTo(2000));
      expect(style.duration.inMilliseconds, lessThanOrEqualTo(4000));
    }
  });
}
