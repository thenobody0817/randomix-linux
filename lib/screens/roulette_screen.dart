import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/recent_store.dart';
import '../core/roulette_logic.dart';
import '../core/spin_style.dart';
import '../services/sound_service.dart';
import '../state/prefs.dart';
import '../state/settings_controller.dart';
import '../state/tool_shortcuts.dart';
import '../strings.dart';
import '../widgets/randomize_button.dart';
import '../widgets/recent_sets_sheet.dart';
import '../widgets/result_text.dart';
import '../widgets/spin_visuals.dart';

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen>
    with TickerProviderStateMixin {
  late final ToolShortcuts _shortcuts;

  final TextEditingController _input = TextEditingController();
  final TextEditingController _min = TextEditingController();
  final TextEditingController _max = TextEditingController();
  final Random _random = Random();

  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    reverseDuration: const Duration(milliseconds: 250),
    value: 1,
  );

  /// Drives whichever spin visual is selected in the settings.
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: RouletteSpinStyle.wheel.duration,
  );

  List<String> _options = [];
  bool _rangeMode = false;
  bool _busy = false;
  bool _spinning = false;
  int _spinWinner = 0;
  int _spinMin = 0;
  int _spinMax = 0;
  RouletteSpinStyle _spinStyle = RouletteSpinStyle.wheel;
  String? _result;

  @override
  void initState() {
    super.initState();
    final store = context.read<PrefsStore>();
    _rangeMode = store.getBool(K.rouletteRangeMode);
    _min.text = store.getString(K.rouletteRangeMin) ?? '';
    _max.text = store.getString(K.rouletteRangeMax) ?? '';
    final raw = store.getString(K.rouletteOptions);
    if (raw != null) {
      try {
        final data = jsonDecode(raw);
        if (data is List) {
          _options = data.map((e) => e.toString()).toList();
        }
      } on FormatException {
        _options = [];
      }
    }
    _spinStyle = context.read<SettingsController>().spinStyle;
    _shortcuts = context.read<ToolShortcuts>();
    _shortcuts.register('roulette', _runSpin);
  }

  @override
  void dispose() {
    _shortcuts.unregister('roulette', _runSpin);
    _input.dispose();
    _min.dispose();
    _max.dispose();
    _fade.dispose();
    _spin.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- storage

  Future<void> _saveOptions() => context.read<PrefsStore>().setString(
    K.rouletteOptions,
    jsonEncode(_options),
  );

  Future<void> _saveRange() async {
    final store = context.read<PrefsStore>();
    await store.setString(K.rouletteRangeMin, _min.text);
    await store.setString(K.rouletteRangeMax, _max.text);
  }

  Future<void> _saveRangeMode(bool value) =>
      context.read<PrefsStore>().setBool(K.rouletteRangeMode, value);

  // ------------------------------------------------------------------ helpers

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
      );
  }

  void _setRangeMode(bool value) {
    setState(() => _rangeMode = value);
    _saveRangeMode(value);
  }

  void _addOption() {
    final settings = context.read<SettingsController>();
    final outcome = RouletteLogic.tryAdd(
      _options,
      _input.text,
      allowEquals: settings.allowEquals,
    );
    switch (outcome) {
      case OptionAddResult.added:
        _input.clear();
        setState(() {});
        _saveOptions();
      case OptionAddResult.empty:
        break;
      case OptionAddResult.duplicate:
        _snack(S.duplicateOption);
      case OptionAddResult.full:
        _snack(S.tooMuchEntries);
    }
  }

  void _removeOption(int index) {
    setState(() => _options.removeAt(index));
    _saveOptions();
  }

  // -------------------------------------------------------------------- spin

  Future<void> _runSpin() async {
    if (_busy) return;
    final settings = context.read<SettingsController>();
    final store = context.read<PrefsStore>();
    final sound = context.read<SoundController>();

    late final String reveal;
    var winnerIndex = 0;

    if (_rangeMode) {
      final range = RouletteLogic.parseRange(_min.text, _max.text);
      if (range == null) {
        _snack(S.wrongRange);
        return;
      }
      _spinMin = range.min;
      _spinMax = range.max;
      reveal =
          '${RouletteLogic.pickNumber(_random, min: range.min, max: range.max)}';
    } else {
      if (_options.length < RouletteLogic.minOptionsToSpin) {
        _snack(S.noEntryRoulette);
        return;
      }

      final recents = RecentStore.decode(store.getString(K.recent));
      final outcome = recents.add(List<String>.of(_options));
      if (outcome == RecentAddResult.added) {
        await store.setString(K.recent, recents.encode());
      } else if (outcome == RecentAddResult.noRoom) {
        _snack(S.noRecentRoom);
      }

      winnerIndex = _random.nextInt(_options.length);
      reveal = _options[winnerIndex];
    }

    setState(() {
      _busy = true;
      _spinning = true;
      _spinStyle = settings.spinStyle;
      _spinWinner = winnerIndex;
      _result = null;
    });
    _fade.value = 0;

    await sound.play(SoundId.roulette);
    _spin.duration = _rangeMode
        ? const Duration(milliseconds: 1400)
        : _spinStyle.duration;
    await _spin.forward(from: 0);
    if (!mounted) return;

    setState(() {
      _spinning = false;
      _result = reveal;
    });
    await _fade.forward();
    if (!mounted) return;

    if (!_rangeMode && settings.removeLast) {
      final index = _options.indexOf(reveal);
      if (index >= 0) {
        setState(() => _options.removeAt(index));
        await _saveOptions();
      }
    }
    setState(() => _busy = false);
  }

  // ------------------------------------------------------------- long press

  Future<void> _onLongPress() async {
    if (_rangeMode) {
      if (_min.text.trim().isEmpty && _max.text.trim().isEmpty) {
        setState(() {
          _min.text = '1';
          _max.text = '10';
        });
      } else {
        setState(() {
          _min.clear();
          _max.clear();
        });
      }
      await _saveRange();
      return;
    }

    if (_options.isEmpty) {
      setState(() => _options.addAll(RouletteLogic.genericOptions()));
      await _saveOptions();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(S.deleteAll),
        content: const Text(S.deleteAllConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(S.deleteAll),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _options.clear());
      await _saveOptions();
    }
  }

  // ------------------------------------------------------------------ recents

  Future<void> _openRecent() async {
    final store = context.read<PrefsStore>();
    final recents = RecentStore.decode(store.getString(K.recent));

    final selection = await showModalBottomSheet<RecentSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => RecentSetsSheet(
        store: recents,
        onSave: (updated) async {
          await store.setString(K.recent, updated.encode());
        },
      ),
    );

    if (selection == null || !mounted) return;
    setState(() {
      _rangeMode = false;
      _options = List<String>.of(selection.options);
    });
    await _saveRangeMode(false);
    await _saveOptions();
  }

  Future<void> _copyResult() async {
    final value = _result;
    if (value == null) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    _snack(S.copiedResult);
  }

  // -------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              children: [
                ScreenDescription(
                  text: S.rouletteDescription,
                  visible: !settings.hideDescriptions,
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text(S.options),
                      icon: Icon(Icons.list_alt),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text(S.range),
                      icon: Icon(Icons.numbers),
                    ),
                  ],
                  selected: {_rangeMode},
                  onSelectionChanged: _busy
                      ? null
                      : (values) => _setRangeMode(values.first),
                ),
                const SizedBox(height: 18),
                if (_spinning &&
                    !_rangeMode &&
                    _spinStyle != RouletteSpinStyle.chips)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _spinVisual(),
                  )
                else if (_rangeMode)
                  _rangeEditor(scheme)
                else
                  _optionsEditor(scheme),
              ],
            ),
          ),
        ),
        _resultArea(),
        const SizedBox(height: 20),
        RandomizeButton(
          label: S.spinRoulette,
          icon: Icons.autorenew,
          enabled: !_busy,
          onPressed: _runSpin,
          onLongPress: _onLongPress,
          tooltip: S.longPressHint,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _spinVisual() {
    switch (_spinStyle) {
      case RouletteSpinStyle.wheel:
        return WheelSpinView(
          progress: _spin,
          options: _options,
          winner: _spinWinner,
        );
      case RouletteSpinStyle.coverflow:
        return CoverFlowSpinView(
          progress: _spin,
          options: _options,
          winner: _spinWinner,
        );
      case RouletteSpinStyle.chips:
        return const SizedBox.shrink();
    }
  }

  Widget _resultArea() {
    return AnimatedBuilder(
      animation: _spin,
      builder: (context, _) {
        final counting = _spinning && _rangeMode;
        final row = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: counting
                  ? NumberReel(
                      progress: _spin,
                      min: _spinMin,
                      max: _spinMax,
                      fontSize: 46,
                    )
                  : ResultText(
                      key: const Key('roulette_result'),
                      value: _result,
                      fontSize: _rangeMode ? 46 : 30,
                      maxLines: _rangeMode ? null : 3,
                    ),
            ),
            if (_result != null)
              IconButton(
                tooltip: S.copyResult,
                onPressed: _copyResult,
                icon: const Icon(Icons.copy_all_outlined, size: 20),
              ),
          ],
        );
        // The number count-up stays visible; everything else fades in.
        return counting ? row : FadeTransition(opacity: _fade, child: row);
      },
    );
  }

  Widget _optionsEditor(ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                enabled: !_busy,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addOption(),
                decoration: InputDecoration(
                  hintText: S.insertRouletteHint,
                  border: const OutlineInputBorder(),
                  helperText: S.insertRouletteDescription,
                  helperMaxLines: 2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: _busy ? null : _addOption,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _openRecent,
            icon: const Icon(Icons.history, size: 18),
            label: const Text(S.recentTitle),
          ),
        ),
        const SizedBox(height: 14),
        if (_options.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              S.insertRouletteDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          )
        else
          AnimatedBuilder(
            animation: _spin,
            builder: (context, _) {
              final active = _spinning && _spinStyle == RouletteSpinStyle.chips
                  ? chipIndexAt(_spin.value, _options.length, _spinWinner)
                  : -1;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < _options.length; i++)
                    InputChip(
                      label: Text(_options[i]),
                      onDeleted: _busy ? null : () => _removeOption(i),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      deleteButtonTooltipMessage: S.removeOption,
                      backgroundColor: active == i
                          ? scheme.primaryContainer
                          : null,
                      labelStyle: active == i
                          ? TextStyle(
                              fontWeight: FontWeight.w700,
                              color: scheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _rangeEditor(ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _min,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                ],
                onChanged: (_) => _saveRange(),
                decoration: const InputDecoration(
                  labelText: S.min,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _max,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                ],
                onChanged: (_) => _saveRange(),
                decoration: const InputDecoration(
                  labelText: S.max,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _openRecent,
            icon: const Icon(Icons.history, size: 18),
            label: const Text(S.recentTitle),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.longPressHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
