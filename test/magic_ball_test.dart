import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:randomix/core/magic_ball_model.dart';

void main() {
  test('default pool has the 30 upstream answers', () {
    expect(MagicBallModel.defaultAnswers.length, 30);
    expect(MagicBallModel.defaultAnswers.first, 'No.');
    expect(MagicBallModel.defaultAnswers.last, 'Ask your best friend.');
  });

  test('rude answers add six entries', () {
    expect(MagicBallModel.rudeAnswers.length, 6);
    final pool = MagicBallModel.pool(
      rude: true,
      customActive: false,
      custom: '',
    );
    expect(pool.length, 36);
    expect(pool, containsAll(MagicBallModel.rudeAnswers));
  });

  test('custom answers split on semicolons and drop empties', () {
    expect(MagicBallModel.parseCustom(' yes ; no ;; maybe ; '), [
      'yes',
      'no',
      'maybe',
    ]);
    expect(MagicBallModel.parseCustom(''), isEmpty);
    expect(MagicBallModel.customIsUsable(' only one '), isFalse);
    expect(MagicBallModel.customIsUsable('one;two'), isTrue);
  });

  test('custom answers replace the defaults only when active and usable', () {
    final active = MagicBallModel.pool(
      rude: true,
      customActive: true,
      custom: 'one;two',
    );
    expect(active, ['one', 'two']);

    final inactive = MagicBallModel.pool(
      rude: false,
      customActive: false,
      custom: 'one;two',
    );
    expect(inactive, MagicBallModel.defaultAnswers);

    final tooShort = MagicBallModel.pool(
      rude: false,
      customActive: true,
      custom: 'only one',
    );
    expect(tooShort.length, 30);
  });

  test('pick always returns a pool member', () {
    final pool = MagicBallModel.pool(
      rude: true,
      customActive: false,
      custom: '',
    );
    for (var seed = 0; seed < 40; seed++) {
      final answer = MagicBallModel.pick(
        rude: true,
        customActive: false,
        custom: '',
        random: Random(seed),
      );
      expect(pool, contains(answer));
    }
  });
}
