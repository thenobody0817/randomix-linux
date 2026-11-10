import 'package:flutter/material.dart';

import '../core/magic_ball_model.dart';
import '../strings.dart';

class MagicAnswersResult {
  const MagicAnswersResult(this.custom, this.active);

  final String custom;
  final bool active;
}

/// Editor for the magic ball's custom answers, the port of the Android bottom
/// sheet: one field, semicolon separated, and a toggle.
class MagicAnswersSheet extends StatefulWidget {
  const MagicAnswersSheet({
    super.key,
    required this.custom,
    required this.active,
  });

  final String custom;
  final bool active;

  @override
  State<MagicAnswersSheet> createState() => _MagicAnswersSheetState();
}

class _MagicAnswersSheetState extends State<MagicAnswersSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.custom,
  );
  late bool _active = widget.active;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _answers => MagicBallModel.parseCustom(_controller.text);

  void _remove(String answer) {
    final remaining = MagicBallModel.parseCustom(_controller.text)
      ..remove(answer);
    setState(() => _controller.text = remaining.join('; '));
  }

  void _save() {
    Navigator.of(context).pop(MagicAnswersResult(_controller.text, _active));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final usable = _answers.length >= MagicBallModel.minCustomAnswers;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(S.customAnswers, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            S.customAnswersHelp,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: S.insertAnswerHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          if (_answers.isEmpty)
            Text(
              S.noAnswersMagicBall,
              style: TextStyle(color: scheme.onSurfaceVariant),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final answer in _answers)
                  InputChip(
                    label: Text(answer),
                    onPressed: () => _remove(answer),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _remove(answer),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(S.useCustomAnswers),
            value: _active,
            onChanged: (value) => setState(() => _active = value),
          ),
          if (_active && !usable)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                S.customAnswersHelp,
                style: TextStyle(color: scheme.error),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(S.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _save, child: const Text(S.save)),
            ],
          ),
        ],
      ),
    );
  }
}
