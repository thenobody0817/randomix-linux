library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A drawn die face. Used for the single-D6 pip mode and as the generic die
/// illustration for the other types.
class DiceFace extends StatelessWidget {
  const DiceFace({
    super.key,
    this.value,
    this.size = 160,
    this.rolling = false,
  });

  /// 1..6 for pip faces, `null` for a type-agnostic die.
  final int? value;
  final double size;
  final bool rolling;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DiceFacePainter(
          value: value,
          face: scheme.surfaceContainerHigh,
          pip: scheme.onSurface,
          outline: scheme.outlineVariant,
          highlight: rolling,
          accent: scheme.primary,
        ),
      ),
    );
  }
}

class _DiceFacePainter extends CustomPainter {
  _DiceFacePainter({
    required this.value,
    required this.face,
    required this.pip,
    required this.outline,
    required this.highlight,
    required this.accent,
  });

  final int? value;
  final Color face;
  final Color pip;
  final Color outline;
  final bool highlight;
  final Color accent;

  static const _pipMap = <int, List<int>>{
    1: [4],
    2: [0, 8],
    3: [0, 4, 8],
    4: [0, 2, 6, 8],
    5: [0, 2, 4, 6, 8],
    6: [0, 2, 3, 5, 6, 8],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = RRect.fromRectAndRadius(
      rect.deflate(size.shortestSide * 0.02),
      Radius.circular(size.shortestSide * 0.18),
    );

    canvas.drawRRect(radius, Paint()..color = face);
    canvas.drawRRect(
      radius,
      Paint()
        ..color = highlight ? accent : outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = highlight ? 3 : 2,
    );

    final pips = _pipMap[value];
    if (pips == null) {
      // Generic die: a dotted cross, matching the app's neutral dice look.
      final center = rect.center;
      final dot = Paint()..color = pip.withValues(alpha: 0.35);
      canvas.drawCircle(center, size.shortestSide * 0.06, dot);
      return;
    }

    final cell = size.shortestSide / 4;
    final dotRadius = size.shortestSide * 0.055;
    final paint = Paint()..color = pip;

    for (final index in pips) {
      final col = index % 3;
      final row = index ~/ 3;
      final center = Offset(cell * (col + 1), cell * (row + 1));
      canvas.drawCircle(center, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiceFacePainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.highlight != highlight ||
      oldDelegate.face != face;
}

/// A small coin illustration used by the coin screen.
class CoinFace extends StatelessWidget {
  const CoinFace({super.key, this.side, this.size = 190});

  /// `true` for heads, `false` for tails, `null` while flipping.
  final bool? side;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        scheme.tertiaryContainer,
        scheme.tertiary.withValues(alpha: 0.85),
      ],
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        border: Border.all(color: scheme.outlineVariant, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: side == null
            ? Icon(
                Icons.question_mark,
                key: const ValueKey('unknown'),
                size: size * 0.42,
                color: scheme.onTertiaryContainer.withValues(alpha: 0.7),
              )
            : Text(
                side! ? 'H' : 'T',
                key: ValueKey(side),
                style: TextStyle(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w700,
                  color: scheme.onTertiaryContainer,
                ),
              ),
      ),
    );
  }
}

/// A softly glowing magic ball.
class MagicBallFace extends StatelessWidget {
  const MagicBallFace({super.key, this.size = 220, this.thinking = false});

  final double size;
  final bool thinking;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      scale: thinking ? 0.97 : 1,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            radius: 0.95,
            colors: [
              scheme.primaryContainer,
              scheme.primary,
              scheme.primary.withValues(alpha: 0.75),
            ],
            stops: const [0.0, 0.62, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.35),
              blurRadius: thinking ? 44 : 26,
              spreadRadius: thinking ? 8 : 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Container(
          width: size * 0.34,
          height: size * 0.34,
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.92),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.auto_awesome,
            size: size * 0.2,
            color: scheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Decorative sparkles around a ball, salted with a sine wave for variety.
class SparkleRing extends StatelessWidget {
  const SparkleRing({super.key, required this.child, this.radius = 150});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 6; i++)
            Transform.translate(
              offset: Offset(
                radius * 0.86 * math.cos(i * math.pi / 3),
                radius * 0.86 * math.sin(i * math.pi / 3),
              ),
              child: Icon(
                Icons.circle,
                size: 4,
                color: Theme.of(context).colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.35),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
