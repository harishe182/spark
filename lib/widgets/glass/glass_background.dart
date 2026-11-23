import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Warm gradient wallpaper with soft color blobs so glass surfaces have
/// something to refract against.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF6DD),
                Color(0xFFFFE9E2),
                Color(0xFFFFF8E1),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -40,
          child: _Blob(
            color: SparkTheme.sparkAmber.withValues(alpha: 0.35),
            size: 260,
          ),
        ),
        Positioned(
          bottom: 120,
          left: -60,
          child: _Blob(
            color: SparkTheme.skyBlue.withValues(alpha: 0.28),
            size: 220,
          ),
        ),
        Positioned(
          top: 200,
          left: 40,
          child: _Blob(
            color: SparkTheme.coral.withValues(alpha: 0.22),
            size: 180,
          ),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
