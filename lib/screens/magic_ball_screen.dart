import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/magic_ball_model.dart';
import '../services/sound_service.dart';
import '../state/settings_controller.dart';
import '../state/tool_shortcuts.dart';
import '../strings.dart';
import '../widgets/dice_face.dart';
import '../widgets/magic_answers_sheet.dart';
import '../widgets/randomize_button.dart';
import '../widgets/result_text.dart';

class MagicBallScreen extends StatefulWidget {
  const MagicBallScreen({super.key});

  @override
  State<MagicBallScreen> createState() => _MagicBallScreenState();
}

class _MagicBallScreenState extends State<MagicBallScreen>
    with SingleTickerProviderStateMixin {
  late final ToolShortcuts _shortcuts;

  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
    reverseDuration: const Duration(milliseconds: 1700),
    value: 1,
  );

  String? _answer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _shortcuts = context.read<ToolShortcuts>();
    _shortcuts.register('magicBall', _shake);
  }

  @override
  void dispose() {
    _shortcuts.unregister('magicBall', _shake);
    _fade.dispose();
    super.dispose();
  }

  Future<void> _shake() async {
    if (_busy) return;
    final settings = context.read<SettingsController>();
    final sound = context.read<SoundController>();

    setState(() => _busy = true);
    await sound.play(SoundId.magicball);
    await _fade.reverse();
    if (!mounted) return;

    final answer = MagicBallModel.pick(
      rude: settings.rudeAnswers,
      customActive: settings.customAnswersActive,
      custom: settings.customAnswers,
    );
    setState(() => _answer = answer);
    await _fade.forward();
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _editAnswers() async {
    final settings = context.read<SettingsController>();
    final result = await showModalBottomSheet<MagicAnswersResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => MagicAnswersSheet(
        custom: settings.customAnswers,
        active: settings.customAnswersActive,
      ),
    );
    if (result == null || !mounted) return;
    await settings.setCustomAnswers(result.custom);
    await settings.setCustomAnswersActive(result.active);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final scheme = Theme.of(context).colorScheme;
    final usingCustom =
        settings.customAnswersActive &&
        MagicBallModel.customIsUsable(settings.customAnswers);

    return Column(
      children: [
        ScreenDescription(
          text: S.magicBallDescription,
          visible: !settings.hideDescriptions,
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MagicBallFace(size: 210, thinking: _busy),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: _editAnswers,
                    icon: const Icon(Icons.tune, size: 18),
                    label: Text(
                      usingCustom ? '${S.customAnswers} ✓' : S.customAnswers,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        FadeTransition(
          opacity: _fade,
          child: SizedBox(
            height: 96,
            child: Center(
              child: ResultText(
                value: _answer,
                fontSize: _answer != null && _answer!.length > 24 ? 22 : 28,
                maxLines: 3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        RandomizeButton(
          label: S.shakeBall,
          icon: Icons.auto_awesome,
          enabled: !_busy,
          onPressed: _shake,
        ),
        if (usingCustom)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              S.useCustomAnswers,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
