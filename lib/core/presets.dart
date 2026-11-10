/// Built-in option presets, matching the Android app.
///
/// Cards are suit-major (`A♠ … K♣`), value first then symbol, exactly as
/// upstream builds them.
library;

class Presets {
  const Presets._();

  static const List<String> letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  static List<String> get numbers =>
      List<String>.generate(100, (i) => '${i + 1}');

  static List<String> get cards {
    const suits = ['♠', '♥', '♦', '♣'];
    const values = [
      'A',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K',
    ];
    return [
      for (final suit in suits)
        for (final value in values) '$value$suit',
    ];
  }
}
