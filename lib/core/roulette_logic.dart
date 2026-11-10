/// Roulette rules, ported one-to-one from the Android fragment.
library;

import 'dart:math';

/// Outcome of trying to add an option to the roulette.
enum OptionAddResult { added, empty, duplicate, full }

class RouletteLogic {
  const RouletteLogic._();

  /// Upstream `MAX_OPTIONS`.
  static const int maxOptions = 30;

  /// Smallest number of options that can be spun.
  static const int minOptionsToSpin = 2;

  /// Trim, then collapse every internal whitespace run to a single space.
  static String normalize(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Adds [raw] to [options] in place, following the upstream rules.
  static OptionAddResult tryAdd(
    List<String> options,
    String raw, {
    required bool allowEquals,
  }) {
    final option = normalize(raw);
    if (option.isEmpty) return OptionAddResult.empty;
    if (!allowEquals && options.contains(option)) {
      return OptionAddResult.duplicate;
    }
    if (options.length >= maxOptions) return OptionAddResult.full;
    options.add(option);
    return OptionAddResult.added;
  }

  /// Parses the custom range. Returns `null` unless both fields are valid
  /// integers and `min < max` (equal values are rejected, as upstream does).
  static ({int min, int max})? parseRange(String minText, String maxText) {
    final min = int.tryParse(minText.trim());
    final max = int.tryParse(maxText.trim());
    if (min == null || max == null || min >= max) return null;
    return (min: min, max: max);
  }

  /// Inclusive pick. Dart integers are 64-bit, so spans beyond 2^31 are safe.
  static int pickNumber(Random random, {required int min, required int max}) =>
      min + random.nextInt(max - min + 1);

  static String pickOption(List<String> options, Random random) =>
      options[random.nextInt(options.length)];

  /// The three generic options added by a long press on an empty list.
  static List<String> genericOptions() => [
    for (var i = 1; i <= 3; i++) 'Option$i',
  ];
}
