/// Recent roulette option sets, ported from `RecentUtils`.
///
/// The Android app stores a `List<List<String>>` as Gson JSON inside the
/// `recent` preference. Pinning is encoded as a trailing sentinel string, which
/// this port keeps byte-for-byte compatible in shape (JSON via `dart:convert`).
library;

import 'dart:convert';

/// Result of trying to remember a set of options.
enum RecentAddResult { added, duplicate, empty, noRoom }

class RecentSet {
  RecentSet({required List<String> options, this.pinned = false})
    : options = List<String>.unmodifiable(options);

  /// The Android workaround: a pinned set carries this as its last element.
  static const String pinSentinel = 'HorribleWorkaroundToPin';

  final List<String> options;
  final bool pinned;

  /// Storage shape: options, plus the sentinel when pinned.
  List<String> toJsonList() => [...options, if (pinned) pinSentinel];

  factory RecentSet.fromJson(Object? raw) {
    final list = raw is List
        ? raw.map((e) => e.toString()).toList()
        : const <String>[];
    final pinned = list.isNotEmpty && list.last == pinSentinel;
    final options = list.where((e) => e != pinSentinel).toList();
    return RecentSet(options: options, pinned: pinned);
  }

  /// Order-insensitive identity of the option set, ignoring the sentinel.
  List<String> get signature => [...options]..sort();

  String get display => options.join(' | ');
}

class RecentStore {
  RecentStore([List<RecentSet>? sets]) : sets = sets ?? <RecentSet>[];

  /// Upstream keeps at most ten sets.
  static const int maxSets = 10;

  /// Oldest first; [latest] is the last element.
  final List<RecentSet> sets;

  bool get isEmpty => sets.isEmpty;

  RecentSet? get latest => sets.isEmpty ? null : sets.last;

  factory RecentStore.decode(String? raw) {
    if (raw == null || raw.isEmpty) return RecentStore();
    try {
      final data = jsonDecode(raw);
      if (data is! List) return RecentStore();
      final store = RecentStore(
        [for (final entry in data) RecentSet.fromJson(entry)]
          ..removeWhere((s) => s.options.isEmpty),
      );
      return store;
    } on FormatException {
      return RecentStore();
    }
  }

  String encode() => jsonEncode([for (final set in sets) set.toJsonList()]);

  bool _sameSignature(RecentSet a, List<String> signature) {
    final other = a.signature;
    if (other.length != signature.length) return false;
    for (var i = 0; i < other.length; i++) {
      if (other[i] != signature[i]) return false;
    }
    return true;
  }

  /// Remembers [options] unless the same set is already stored.
  RecentAddResult add(List<String> options) {
    if (options.isEmpty) return RecentAddResult.empty;
    final signature = [...options]..sort();
    if (sets.any((s) => _sameSignature(s, signature))) {
      return RecentAddResult.duplicate;
    }
    if (sets.length >= maxSets) {
      final evict = sets.indexWhere((s) => !s.pinned);
      // Everything is pinned: upstream silently drops the new set, we report it.
      if (evict == -1) return RecentAddResult.noRoom;
      sets.removeAt(evict);
    }
    sets.add(RecentSet(options: options));
    return RecentAddResult.added;
  }

  void removeAt(int index) {
    if (index >= 0 && index < sets.length) sets.removeAt(index);
  }

  void togglePin(int index) {
    if (index < 0 || index >= sets.length) return;
    final set = sets[index];
    sets[index] = RecentSet(options: set.options, pinned: !set.pinned);
  }

  /// Restoring bypasses the 30-option cap, like upstream.
  List<String>? restore(int index) {
    if (index < 0 || index >= sets.length) return null;
    return List<String>.from(sets[index].options);
  }
}
