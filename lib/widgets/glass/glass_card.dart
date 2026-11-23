import 'package:flutter/material.dart';

import 'glass_surface.dart';
import 'glass_theme.dart';

/// Drop-in glass replacement for Material [Card].
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.0,
    this.light = false,
    this.clouded = false,
    this.onTap,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final bool light;
  final bool clouded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? SparkGlassTheme.defaultRadius;
    final blurSigma = clouded
        ? SparkGlassTheme.cloudedBlur
        : (light ? SparkGlassTheme.lightBlur : null);
    final tintOpacity = clouded
        ? SparkGlassTheme.cloudedTintOpacity
        : (light ? SparkGlassTheme.lightTintOpacity : null);
    final surface = GlassSurface(
      margin: margin,
      borderRadius: radius,
      blurSigma: blurSigma,
      tintOpacity: tintOpacity,
      tintColor: color,
      borderColor: borderColor ?? (clouded ? SparkGlassTheme.edgeLight : null),
      borderWidth: clouded ? 1.5 : borderWidth,
      padding: padding,
      child: child,
    );

    if (onTap == null) return surface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: surface,
      ),
    );
  }
}
