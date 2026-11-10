/// How the roulette reveals its result.
library;

enum RouletteSpinStyle {
  /// Wheel with the current option read out in the hub.
  wheel('wheel', 3000),

  /// Cards sliding past each other in perspective.
  coverflow('coverflow', 3000),

  /// The option chips light up in sequence.
  chips('chips', 2600);

  const RouletteSpinStyle(this.id, this.durationMs);

  final String id;
  final int durationMs;

  Duration get duration => Duration(milliseconds: durationMs);

  static RouletteSpinStyle fromId(String? id) => RouletteSpinStyle.values
      .firstWhere((style) => style.id == id, orElse: () => wheel);
}
