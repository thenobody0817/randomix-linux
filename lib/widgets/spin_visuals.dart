/// Spin visuals for the roulette: a wheel with a centre readout, and a cover
/// flow of cards. Both are driven by an external animation so the screen owns
/// the timing and can await the reveal.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

const Color _ink = Color(0xFF0B0F15);

/// A soft, evenly spread palette that works for 2 to 30 options.
Color sectorColor(int index, int count) {
  final hue = (index * 360 / count) % 360;
  return HSLColor.fromAHSL(1, hue, 0.52, 0.6).toColor();
}

/// Fraction of the way through the highlight race, expressed as a chip index.
int chipIndexAt(double t, int count, int winner) {
  if (count == 0) return 0;
  final eased = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
  final total = count * 4 + winner;
  return (eased * total).floor() % count;
}

/// Wheel with the option currently under the pointer shown in the hub.
class WheelSpinView extends StatelessWidget {
  const WheelSpinView({
    super.key,
    required this.progress,
    required this.options,
    required this.winner,
    this.size = 238,
  });

  final Animation<double> progress;
  final List<String> options;
  final int winner;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          if (options.isEmpty) return const SizedBox.shrink();
          final count = options.length;
          final segment = 360 / count;
          final finalRotation = -(winner * segment + segment / 2);
          final eased = Curves.easeOutCubic.transform(progress.value);
          final rotation = (finalRotation + 360 * 4) * eased;
          final normalized = ((rotation % 360) + 360) % 360;
          final underPointer = (normalized / segment).floor() % count;
          final finished = progress.value >= 1;

          return CustomPaint(
            painter: _WheelPainter(
              options: options,
              rotationDeg: rotation,
              hubText: options[finished ? winner : underPointer],
              highlight: finished ? winner : null,
              scheme: scheme,
            ),
          );
        },
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.options,
    required this.rotationDeg,
    required this.hubText,
    required this.highlight,
    required this.scheme,
  });

  final List<String> options;
  final double rotationDeg;
  final String hubText;
  final int? highlight;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final count = options.length;
    if (count == 0) return;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 12;
    final segment = 360 / count;
    final arc = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius + 7,
      Paint()..color = const Color(0xFF0A0E14),
    );
    canvas.drawCircle(
      center,
      radius + 7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = scheme.outlineVariant.withValues(alpha: 0.6),
    );

    for (var i = 0; i < count; i++) {
      final start = (rotationDeg - 90 + i * segment) * math.pi / 180;
      final sweep = segment * math.pi / 180;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(arc, start, sweep, false)
        ..close();

      canvas.drawPath(path, Paint()..color = sectorColor(i, count));
      if (highlight == i) {
        canvas.drawPath(
          path,
          Paint()..color = Colors.white.withValues(alpha: 0.3),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.black.withValues(alpha: 0.22),
      );

      // Above twelve slices the labels become noise; the hub carries the text.
      if (count <= 12) {
        final mid =
            (rotationDeg - 90 + i * segment + segment / 2) * math.pi / 180;
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(mid);
        final label = TextPainter(
          text: TextSpan(
            text: options[i],
            style: TextStyle(
              fontSize: count <= 8 ? 11 : 9,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '…',
        )..layout(maxWidth: radius * 0.55);
        label.paint(
          canvas,
          Offset(radius - 14 - label.width, -label.height / 2),
        );
        canvas.restore();
      }
    }

    // Hub with the live readout.
    canvas.drawCircle(center, 31, Paint()..color = scheme.surface);
    canvas.drawCircle(
      center,
      31,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = scheme.outlineVariant,
    );
    final hub = TextPainter(
      text: TextSpan(
        text: hubText,
        style: TextStyle(
          fontSize: hubText.length > 12 ? 9 : 11,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: 52);
    hub.paint(canvas, center - Offset(hub.width / 2, hub.height / 2));

    // Fixed pointer at the top.
    final pointer = Path()
      ..moveTo(center.dx - 8, center.dy - radius - 16)
      ..lineTo(center.dx + 8, center.dy - radius - 16)
      ..lineTo(center.dx, center.dy - radius + 4)
      ..close();
    canvas.drawPath(pointer, Paint()..color = scheme.onSurface);

    if (highlight != null) {
      final start = (rotationDeg - 90 + highlight! * segment) * math.pi / 180;
      final sweep = segment * math.pi / 180;
      final win = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(arc, start, sweep, false)
        ..close();
      canvas.drawPath(
        win,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) =>
      old.rotationDeg != rotationDeg ||
      old.hubText != hubText ||
      old.highlight != highlight ||
      old.options != options ||
      old.scheme != scheme;
}

/// Cards sliding in perspective until the winner sits in front.
class CoverFlowSpinView extends StatelessWidget {
  const CoverFlowSpinView({
    super.key,
    required this.progress,
    required this.options,
    required this.winner,
  });

  final Animation<double> progress;
  final List<String> options;
  final int winner;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 196,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          final count = options.length;
          if (count == 0) return const SizedBox.shrink();
          final eased = Curves.easeOutCubic.transform(progress.value);
          final position = eased * (count * 2 + winner);

          final entries = <({int index, double relative})>[];
          for (var i = 0; i < count; i++) {
            var relative = (i - position) % count;
            if (relative < 0) relative += count;
            if (relative > count / 2) relative -= count;
            entries.add((index: i, relative: relative));
          }
          // Draw the furthest cards first so the front one is on top.
          entries.sort((a, b) => b.relative.abs().compareTo(a.relative.abs()));

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              for (final entry in entries)
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..translateByDouble(entry.relative * 82, 0, 0, 1)
                    ..rotateY(-entry.relative * 0.42)
                    ..scaleByDouble(
                      1 - entry.relative.abs() * 0.07,
                      1 - entry.relative.abs() * 0.07,
                      1,
                      1,
                    ),
                  child: Opacity(
                    opacity: (1 - entry.relative.abs() * 0.16).clamp(0.12, 1.0),
                    child: _CoverCard(
                      text: options[entry.index],
                      color: sectorColor(entry.index, count),
                      scheme: scheme,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CoverCard extends StatelessWidget {
  const _CoverCard({
    required this.text,
    required this.color,
    required this.scheme,
  });

  final String text;
  final Color color;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _ink,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// The number flicker used for range mode, where there are no option chips.
class NumberReel extends StatelessWidget {
  const NumberReel({
    super.key,
    required this.progress,
    required this.min,
    required this.max,
    required this.fontSize,
  });

  final Animation<double> progress;
  final int min;
  final int max;
  final double fontSize;

  String _value() {
    final span = max - min;
    if (span <= 0) return '$min';
    final noise = (math.sin(progress.value * 1200) * 43758.5453).abs();
    return '${min + (noise % (span + 1)).floor()}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) => Text(
        _value(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
