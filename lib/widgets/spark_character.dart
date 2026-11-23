import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The Spark helper logo: a smiling five-point star with rounded tips, soft
/// eyes, and little sparkle marks. Deliberately friendly and non-technical —
/// never a robot, never an "AI" label (study requirement).
///
/// Drawn with a [CustomPainter] so it scales crisply and needs no asset.
class SparkCharacter extends StatelessWidget {
  const SparkCharacter({super.key, this.size = 96, this.showSparkles = true});

  final double size;
  final bool showSparkles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SparkPainter(showSparkles: showSparkles),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.showSparkles});

  final bool showSparkles;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Star body with a soft amber gradient fill.
    final starPath = _roundedStarPath(center, radius, radius * 0.5, 5);
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        colors: [SparkTheme.sparkYellow, SparkTheme.sparkAmber],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(starPath, bodyPaint);

    // Subtle outline.
    canvas.drawPath(
      starPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.02
        ..color = SparkTheme.sparkAmber.withValues(alpha: 0.6),
    );

    // Face.
    final eyePaint = Paint()..color = SparkTheme.ink;
    final eyeR = size.width * 0.035;
    canvas.drawCircle(
        center.translate(-radius * 0.28, -radius * 0.05), eyeR, eyePaint);
    canvas.drawCircle(
        center.translate(radius * 0.28, -radius * 0.05), eyeR, eyePaint);

    // Smile.
    final smileRect = Rect.fromCircle(
      center: center.translate(0, radius * 0.05),
      radius: radius * 0.28,
    );
    canvas.drawArc(
      smileRect,
      0.15 * math.pi,
      0.7 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.025
        ..strokeCap = StrokeCap.round
        ..color = SparkTheme.ink,
    );

    if (showSparkles) {
      final sparkPaint = Paint()..color = SparkTheme.sparkYellow;
      _drawSparkle(canvas, center.translate(radius * 1.05, -radius * 0.9),
          size.width * 0.05, sparkPaint);
      _drawSparkle(canvas, center.translate(-radius * 1.1, -radius * 0.5),
          size.width * 0.035, sparkPaint);
    }
  }

  /// Builds a star with [points] tips, alternating [outerR]/[innerR], with
  /// the corners smoothed slightly so it reads as friendly rather than sharp.
  Path _roundedStarPath(Offset c, double outerR, double innerR, int points) {
    final path = Path();
    final step = math.pi / points;
    var angle = -math.pi / 2;
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final point = Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      angle += step;
    }
    path.close();
    return path;
  }

  void _drawSparkle(Canvas canvas, Offset c, double r, Paint paint) {
    final path = _roundedStarPath(c, r, r * 0.4, 4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) =>
      oldDelegate.showSparkles != showSparkles;
}
