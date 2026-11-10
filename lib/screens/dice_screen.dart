import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/dice_roller.dart';
import '../services/sound_service.dart';
import '../state/settings_controller.dart';
import '../state/tool_shortcuts.dart';
import '../strings.dart';
import '../widgets/dice_face.dart';
import '../widgets/randomize_button.dart';
import '../widgets/result_text.dart';

class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key});

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen>
    with SingleTickerProviderStateMixin {
  late final ToolShortcuts _shortcuts;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  late DiceType _type;
  late int _count;
  DiceRoll? _roll;
  bool _rolling = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsController>();
    _type = settings.diceType;
    _count = settings.diceCount;
    _shortcuts = context.read<ToolShortcuts>();
    _shortcuts.register('dice', _throwDice);
  }

  @override
  void dispose() {
    _shortcuts.unregister('dice', _throwDice);
    _anim.dispose();
    super.dispose();
  }

  void _setType(DiceType type) {
    setState(() => _type = type);
    context.read<SettingsController>().setDiceType(type);
  }

  void _setCount(int count) {
    setState(() => _count = count);
    context.read<SettingsController>().setDiceCount(count);
  }

  Future<void> _throwDice() async {
    if (_rolling) return;
    setState(() => _rolling = true);
    await context.read<SoundController>().play(SoundId.dice);
    await _anim.forward(from: 0);
    if (!mounted) return;
    final roll = DiceRoller.roll(
      type: _count == threeVsThreeCount ? DiceType.d6 : _type,
      count: _count,
    );
    setState(() {
      _roll = roll;
      _rolling = false;
    });
  }

  bool get _threeVsThree => _count == threeVsThreeCount;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final scheme = Theme.of(context).colorScheme;
    final effectiveType = _threeVsThree ? DiceType.d6 : _type;
    final pips = DiceRoller.usesPips(type: effectiveType, count: _count);

    return Column(
      children: [
        ScreenDescription(
          text: S.diceDescription,
          visible: !settings.hideDescriptions,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.diceType,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final type in DiceType.values)
                      ChoiceChip(
                        label: Text(type.label),
                        selected: effectiveType == type,
                        onSelected: _threeVsThree
                            ? null
                            : (_) => _setType(type),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  S.diceNumber,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 1; i <= maxDiceCount; i++)
                      ChoiceChip(
                        label: Text('$i'),
                        selected: _count == i,
                        onSelected: (_) => _setCount(i),
                      ),
                    ChoiceChip(
                      label: const Text(S.threeVThree),
                      selected: _threeVsThree,
                      onSelected: (_) => _setCount(threeVsThreeCount),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (context, child) {
                      final t = _anim.value;
                      const shakePortion = 0.24;
                      var dx = 0.0;
                      var spin = 0.0;
                      if (t < shakePortion) {
                        final local = t / shakePortion;
                        dx = 20 * math.sin(local * 3 * math.pi) * (1 - local);
                      } else {
                        spin =
                            ((t - shakePortion) / (1 - shakePortion)) *
                            2 *
                            math.pi;
                      }
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0015)
                          ..translateByDouble(dx, 0.0, 0.0, 1.0)
                          ..rotateY(spin),
                        child: child,
                      );
                    },
                    child: _roll == null || _rolling
                        ? DiceFace(
                            value: pips && _roll != null
                                ? _roll!.values.first
                                : null,
                            size: 150,
                          )
                        : pips
                        ? DiceFace(value: _roll!.values.first, size: 150)
                        : DiceFace(value: null, size: 130),
                  ),
                ),
                const SizedBox(height: 12),
                if (_roll != null && !pips && !_rolling)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final value in _roll!.values)
                        Chip(
                          label: Text(
                            '$value',
                            style: TextStyle(
                              fontWeight: value == effectiveType.sides
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                          backgroundColor: value == effectiveType.sides
                              ? scheme.primaryContainer
                              : scheme.surfaceContainerHigh,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ResultText(
          value: _roll?.display,
          showLabel: true,
          fontSize: _threeVsThree ? 34 : 30,
        ),
        const SizedBox(height: 20),
        RandomizeButton(
          label: S.throwDice,
          icon: Icons.casino_outlined,
          enabled: !_rolling,
          onPressed: _throwDice,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
