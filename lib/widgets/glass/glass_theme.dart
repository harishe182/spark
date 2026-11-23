import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Spark-tuned liquid glass defaults: warm tint, soft specular edge, rounded
/// corners. Used by all glass wrapper widgets.
class SparkGlassTheme {
  SparkGlassTheme._();

  static const double defaultBlur = 18;
  static const double lightBlur = 12;
  /// Denser frosted glass for dialogs and overlays.
  static const double cloudedBlur = 32;
  static const double defaultTintOpacity = 0.55;
  static const double lightTintOpacity = 0.72;
  static const double cloudedTintOpacity = 0.82;
  static const BorderRadius defaultRadius = BorderRadius.all(Radius.circular(24));

  static Color tint(BuildContext context) =>
      Colors.white.withValues(alpha: defaultTintOpacity);

  static Color lightTint(BuildContext context) =>
      Colors.white.withValues(alpha: lightTintOpacity);

  static Color get edgeLight => Colors.white.withValues(alpha: 0.65);

  static Color get edgeShadow => SparkTheme.ink.withValues(alpha: 0.08);

  static Color get solidFallback => SparkTheme.cream;

  /// When true, glass degrades to an opaque surface (accessibility / perf).
  static bool shouldUseSolid(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.highContrastOf(context);
  }
}
