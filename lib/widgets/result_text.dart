library;

import 'package:flutter/material.dart';

import '../strings.dart';

/// The big result line. Shows the placeholder until something is thrown.
class ResultText extends StatelessWidget {
  const ResultText({
    super.key,
    required this.value,
    this.showLabel = false,
    this.fontSize = 34,
    this.maxLines,
  });

  final String? value;
  final bool showLabel;
  final double fontSize;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = value ?? S.resultPlaceholder;
    final isPlaceholder = value == null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      child: Text(
        showLabel && !isPlaceholder ? '${S.genericResult} $text' : text,
        key: ValueKey(text),
        textAlign: TextAlign.center,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isPlaceholder ? FontWeight.w300 : FontWeight.w600,
          color: isPlaceholder
              ? scheme.onSurfaceVariant.withValues(alpha: 0.6)
              : scheme.onSurface,
          letterSpacing: isPlaceholder ? 2 : 0,
        ),
      ),
    );
  }
}

/// A screen's description, hidden when the user turns descriptions off.
class ScreenDescription extends StatelessWidget {
  const ScreenDescription({
    super.key,
    required this.text,
    required this.visible,
  });

  final String text;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
