/// Magic ball answers and rules, ported from `MagicBallFragment`.
library;

import 'dart:math';

class MagicBallModel {
  const MagicBallModel._();

  /// At least this many custom answers are required to use them.
  static const int minCustomAnswers = 2;

  static const List<String> defaultAnswers = [
    'No.',
    'Yes!',
    "I don't think so.",
    'Maybe!',
    'This makes no sense.',
    'Probably…',
    'Are you sure?',
    'Probably yes.',
    'Probably no.',
    'Of course.',
    'Ask it yourself.',
    'No, absurd.',
    'Hell yeah!',
    'Think about it.',
    'Who knows.',
    'Are you kidding?',
    'As I see it, yes.',
    'It is certain.',
    'It is decidedly so.',
    'Outlook good.',
    'Signs point to yes.',
    'Without a doubt.',
    'Reply hazy, try again.',
    'Better not tell you now.',
    'Cannot predict now!',
    'Concentrate and ask again.',
    "Don't count on it.",
    'My sources say no.',
    'Very doubtful.',
    'Ask your best friend.',
  ];

  /// Appended to the defaults when the "rude answers" setting is on.
  static const List<String> rudeAnswers = [
    'No, idiot.',
    'Of course, dammit.',
    'Are you stupid?',
    'Lol! How stupid.',
    "You're crazy.",
    'Go to hell.',
  ];

  /// Splits the custom answers field on `;`, trimming and dropping empties.
  static List<String> parseCustom(String raw) =>
      raw.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  static bool customIsUsable(String raw) =>
      parseCustom(raw).length >= minCustomAnswers;

  /// The pool a throw picks from: custom answers fully replace the defaults
  /// only when the toggle is on and there are at least two of them.
  static List<String> pool({
    required bool rude,
    required bool customActive,
    required String custom,
  }) {
    if (customActive && customIsUsable(custom)) return parseCustom(custom);
    return [...defaultAnswers, if (rude) ...rudeAnswers];
  }

  static String pick({
    required bool rude,
    required bool customActive,
    required String custom,
    Random? random,
  }) {
    final answers = pool(
      rude: rude,
      customActive: customActive,
      custom: custom,
    );
    final rnd = random ?? Random();
    return answers[rnd.nextInt(answers.length)];
  }
}
