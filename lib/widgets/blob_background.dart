library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Slowly drifting coloured blobs, the port of `BlobBackgroundView`.
///
/// Two or three soft radial gradients wander around the window. It is ambient
/// decoration only: it ignores pointers and can be paused.
class BlobBackground extends StatefulWidget {
  const BlobBackground({
    super.key,
    required this.child,
    this.enabled = true,
    this.paused = false,
  });

  final Widget child;
  final bool enabled;
  final bool paused;

  @override
  State<BlobBackground> createState() => _BlobBackgroundState();
}

class _BlobBackgroundState extends State<BlobBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled && !widget.paused) _controller.repeat();
  }

  @override
  void didUpdateWidget(BlobBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldRun = widget.enabled && !widget.paused;
    if (shouldRun && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldRun && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _BlobPainter(
                progress: _controller.value,
                colors: [
                  scheme.primary.withValues(alpha: 0.16),
                  scheme.tertiary.withValues(alpha: 0.14),
                  scheme.secondary.withValues(alpha: 0.10),
                ],
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({required this.progress, required this.colors});

  final double progress;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;
    final minSide = size.shortestSide;
    final radius = minSide * 0.42;

    Offset at(double phase, double speed) => Offset(
      size.width * (0.5 + 0.34 * math.sin(t * speed + phase)),
      size.height * (0.5 + 0.30 * math.cos(t * speed * 1.3 + phase)),
    );

    final blobs = <({Offset center, Color color})>[
      (center: at(0, 1.0), color: colors[0]),
      (center: at(2.1, 0.8), color: colors[1]),
      (center: at(4.2, 1.15), color: colors[2]),
    ];

    for (final blob in blobs) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [blob.color, blob.color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: blob.center, radius: radius))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
      canvas.drawCircle(blob.center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.colors != colors;
}
