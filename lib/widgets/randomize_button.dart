library;

import 'package:flutter/material.dart';

/// The central action button, with a long-press alternate action
/// (the desktop equivalent of the Android long press).
class RandomizeButton extends StatefulWidget {
  const RandomizeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.onLongPress,
    this.enabled = true,
    this.tooltip,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool enabled;
  final String? tooltip;

  @override
  State<RandomizeButton> createState() => _RandomizeButtonState();
}

class _RandomizeButtonState extends State<RandomizeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    lowerBound: 0.96,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _tap() {
    if (!widget.enabled || widget.onPressed == null) return;
    // The press feedback runs beside the work, never in front of it.
    _pulse.reverse();
    widget.onPressed!.call();
    Future<void>.delayed(const Duration(milliseconds: 90), () {
      if (mounted) _pulse.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final button = ScaleTransition(
      scale: _pulse,
      child: FilledButton.icon(
        onPressed: widget.enabled ? _tap : null,
        icon: AnimatedRotation(
          turns: widget.enabled ? 0 : 0.25,
          duration: const Duration(milliseconds: 300),
          child: Icon(widget.icon, size: 24),
        ),
        label: Text(
          widget.label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          disabledBackgroundColor: scheme.surfaceContainerHighest,
          disabledForegroundColor: scheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: const StadiumBorder(),
        ),
      ),
    );

    final withGesture = GestureDetector(
      onLongPress: widget.enabled ? widget.onLongPress : null,
      child: button,
    );

    return widget.tooltip == null
        ? withGesture
        : Tooltip(message: widget.tooltip, child: withGesture);
  }
}
