import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sound_service.dart';
import '../state/settings_controller.dart';
import '../state/tool_shortcuts.dart';
import '../strings.dart';
import '../widgets/dice_face.dart';
import '../widgets/randomize_button.dart';
import '../widgets/result_text.dart';

class CoinScreen extends StatefulWidget {
  const CoinScreen({super.key});

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen>
    with SingleTickerProviderStateMixin {
  late final ToolShortcuts _shortcuts;

  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  final math.Random _random = math.Random();
  bool? _result;
  bool _busy = false;
  int _streak = 0;
  Timer? _cooldown;

  @override
  void initState() {
    super.initState();
    _shortcuts = context.read<ToolShortcuts>();
    _shortcuts.register('coin', _flipCoin);
  }

  @override
  void dispose() {
    _shortcuts.unregister('coin', _flipCoin);
    _cooldown?.cancel();
    _flip.dispose();
    super.dispose();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
      );
  }

  void _announceStreak() {
    if (_streak == 3) _snack(S.streakThree);
    if (_streak == 5) _snack(S.streakFive);
    if (_streak == 10) _snack(S.streakTen);
    if (_streak == 20) _snack(S.streakTwenty);
  }

  Future<void> _flipCoin() async {
    if (_busy) return;
    setState(() => _busy = true);

    // The flip takes 1.5 s and the upstream cooldown adds 2 s: one timer keeps
    // the button locked for the whole cycle, independent of frame timing.
    _cooldown?.cancel();
    _cooldown = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _busy = false);
    });

    await context.read<SoundController>().play(SoundId.coin);

    final heads = _random.nextBool();
    await _flip.forward(from: 0);
    if (!mounted) return;

    final previous = _result;
    setState(() {
      _result = heads;
      _streak = previous == heads ? _streak + 1 : 1;
    });
    _announceStreak();

    // Upstream blocks another flip for two seconds.
    _cooldown?.cancel();
    _cooldown = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _busy = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Column(
      children: [
        ScreenDescription(
          text: S.coinDescription,
          visible: !settings.hideDescriptions,
        ),
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: _flip,
              builder: (context, child) {
                final turns = _flip.value * 3;
                final rotation = turns * 2 * math.pi;
                // Squash on the vertical axis to fake the coin turning over.
                final scaleY = math.cos(rotation).abs().clamp(0.12, 1.0);
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    ..rotateX(rotation),
                  child: Transform.scale(scaleY: scaleY, child: child),
                );
              },
              child: CoinFace(
                side: _flip.isAnimating ? null : _result,
                size: 200,
              ),
            ),
          ),
        ),
        ResultText(
          value: _result == null
              ? null
              : (_result! ? S.resultHead : S.resultTail),
          fontSize: 30,
        ),
        const SizedBox(height: 20),
        RandomizeButton(
          label: S.flipCoin,
          icon: Icons.monetization_on_outlined,
          enabled: !_busy,
          onPressed: _flipCoin,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
