import 'package:flutter/material.dart';

import '../core/presets.dart';
import '../core/recent_store.dart';
import '../strings.dart';

/// What the sheet hands back when the user picks something.
class RecentSelection {
  const RecentSelection(this.options);

  final List<String> options;
}

/// Recent option sets plus the three presets, the port of the Android
/// bottom sheet. Pin, delete and restore all persist immediately.
class RecentSetsSheet extends StatefulWidget {
  const RecentSetsSheet({super.key, required this.store, required this.onSave});

  final RecentStore store;
  final Future<void> Function(RecentStore store) onSave;

  @override
  State<RecentSetsSheet> createState() => _RecentSetsSheetState();
}

class _RecentSetsSheetState extends State<RecentSetsSheet> {
  RecentStore get _store => widget.store;

  Future<void> _togglePin(int index) async {
    setState(() => _store.togglePin(index));
    await widget.onSave(_store);
  }

  Future<void> _delete(int index) async {
    setState(() => _store.removeAt(index));
    await widget.onSave(_store);
  }

  void _pick(List<String> options) {
    Navigator.of(context).pop(RecentSelection(options));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final height = MediaQuery.sizeOf(context).height * 0.78;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(S.recentTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              S.recentDescription,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.abc, size: 18),
                  label: const Text(S.lettersShortcut),
                  onPressed: () => _pick(Presets.letters),
                ),
                ActionChip(
                  avatar: const Icon(Icons.tag, size: 18),
                  label: const Text(S.numbersShortcut),
                  onPressed: () => _pick(Presets.numbers),
                ),
                ActionChip(
                  avatar: const Icon(Icons.style_outlined, size: 18),
                  label: const Text(S.cardsShortcut),
                  onPressed: () => _pick(Presets.cards),
                ),
              ],
            ),
            const Divider(height: 28),
            Expanded(
              child: _store.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          S.noRecentOptions,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _store.sets.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        // Newest first in the UI; storage stays oldest-first.
                        final i = _store.sets.length - 1 - index;
                        final set = _store.sets[i];
                        return Dismissible(
                          key: ValueKey('${set.display}-$i-${set.pinned}'),
                          direction: DismissDirection.horizontal,
                          background: _dismissBackground(
                            scheme,
                            Alignment.centerLeft,
                          ),
                          secondaryBackground: _dismissBackground(
                            scheme,
                            Alignment.centerRight,
                          ),
                          onDismissed: (_) => _delete(i),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            tileColor: set.pinned
                                ? scheme.secondaryContainer
                                : scheme.surfaceContainerHigh,
                            leading: Icon(
                              set.pinned ? Icons.push_pin : Icons.history,
                              color: set.pinned
                                  ? scheme.onSecondaryContainer
                                  : scheme.onSurfaceVariant,
                            ),
                            title: Text(
                              set.display,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: set.pinned
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                            subtitle: Text(
                              '${set.options.length} ${S.options.toLowerCase()}',
                            ),
                            onTap: () =>
                                _pick(_store.restore(i) ?? const <String>[]),
                            onLongPress: () => _togglePin(i),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dismissBackground(ColorScheme scheme, Alignment alignment) =>
      Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: scheme.errorContainer,
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      );
}
