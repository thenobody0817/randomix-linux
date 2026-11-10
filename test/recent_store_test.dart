import 'package:flutter_test/flutter_test.dart';
import 'package:randomix/core/recent_store.dart';

void main() {
  group('RecentStore.add', () {
    test('adds new sets and rejects duplicates in any order', () {
      final store = RecentStore();
      expect(store.add(['a', 'b']), RecentAddResult.added);
      expect(store.add(['b', 'a']), RecentAddResult.duplicate);
      expect(store.sets.length, 1);
    });

    test('ignores empty sets', () {
      final store = RecentStore();
      expect(store.add([]), RecentAddResult.empty);
      expect(store.isEmpty, isTrue);
    });

    test('keeps at most ten sets and evicts the oldest unpinned', () {
      final store = RecentStore();
      for (var i = 0; i < 10; i++) {
        store.add(['set$i']);
      }
      expect(store.sets.length, 10);
      expect(store.add(['newest']), RecentAddResult.added);
      expect(store.sets.length, 10);
      expect(store.sets.any((s) => s.options.contains('set0')), isFalse);
      expect(store.latest!.options, ['newest']);
    });

    test('does not evict pinned sets', () {
      final store = RecentStore();
      for (var i = 0; i < 10; i++) {
        store.add(['set$i']);
        store.togglePin(i);
      }
      expect(store.sets.every((s) => s.pinned), isTrue);
      expect(store.add(['newest']), RecentAddResult.noRoom);
      expect(store.sets.length, 10);
    });

    test('evicts the first unpinned when a mix exists', () {
      final store = RecentStore();
      for (var i = 0; i < 10; i++) {
        store.add(['set$i']);
      }
      store.togglePin(0);
      store.add(['newest']);
      expect(store.sets.any((s) => s.options.contains('set0')), isTrue);
      expect(store.sets.any((s) => s.options.contains('set1')), isFalse);
    });
  });

  group('pinning and deletion', () {
    test('togglePin flips and keeps options', () {
      final store = RecentStore()..add(['a', 'b']);
      store.togglePin(0);
      expect(store.sets[0].pinned, isTrue);
      expect(store.sets[0].options, ['a', 'b']);
      store.togglePin(0);
      expect(store.sets[0].pinned, isFalse);
    });

    test('removeAt and restore', () {
      final store = RecentStore()
        ..add(['a'])
        ..add(['b', 'c']);
      expect(store.restore(1), ['b', 'c']);
      store.removeAt(0);
      expect(store.restore(0), ['b', 'c']);
      expect(store.restore(5), isNull);
      // restore returns a copy: mutating it must not touch the store
      store.restore(0)!.add('x');
      expect(store.sets[0].options, ['b', 'c']);
    });
  });

  group('serialisation', () {
    test('round-trips options and pins through JSON', () {
      final store = RecentStore()
        ..add(['a', 'b'])
        ..add(['c']);
      store.togglePin(0);

      final decoded = RecentStore.decode(store.encode());
      expect(decoded.sets.length, 2);
      expect(decoded.sets[0].options, ['a', 'b']);
      expect(decoded.sets[0].pinned, isTrue);
      expect(decoded.sets[1].options, ['c']);
      expect(decoded.sets[1].pinned, isFalse);
    });

    test('the pin sentinel never leaks into options', () {
      final decoded = RecentStore.decode(
        '[["a","b","${RecentSet.pinSentinel}"]]',
      );
      expect(decoded.sets[0].options, ['a', 'b']);
      expect(decoded.sets[0].pinned, isTrue);
      expect(decoded.sets[0].toJsonList().last, RecentSet.pinSentinel);
    });

    test('invalid or missing data decodes to an empty store', () {
      expect(RecentStore.decode(null).isEmpty, isTrue);
      expect(RecentStore.decode('').isEmpty, isTrue);
      expect(RecentStore.decode('not json').isEmpty, isTrue);
      expect(RecentStore.decode('{"a":1}').isEmpty, isTrue);
      expect(RecentStore.decode('[["a"],[]]').sets.length, 1);
    });

    test('display joins with a pipe', () {
      expect(RecentSet(options: ['a', 'b']).display, 'a | b');
    });
  });
}
