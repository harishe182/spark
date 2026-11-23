import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'glass_theme.dart';

/// Core frosted-glass surface: backdrop blur, warm tint, specular rim.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.blurSigma,
    this.tintOpacity,
    this.tintColor,
    this.borderRadius = SparkGlassTheme.defaultRadius,
    this.padding,
    this.width,
    this.height,
    this.margin,
    this.enabled,
    this.borderColor,
    this.borderWidth = 1.0,
    this.showShadow = true,
  });

  final Widget child;
  final double? blurSigma;
  final double? tintOpacity;
  final Color? tintColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final bool? enabled;
  final Color? borderColor;
  final double borderWidth;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final useGlass = enabled ?? !SparkGlassTheme.shouldUseSolid(context);
    final sigma = blurSigma ?? SparkGlassTheme.defaultBlur;
    final tint = tintColor ??
        Colors.white.withValues(
          alpha: tintOpacity ?? SparkGlassTheme.defaultTintOpacity,
        );

    final content = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );

    Widget surface;
    if (useGlass) {
      surface = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tint,
              borderRadius: borderRadius,
              border: Border.all(
                color: borderColor ?? SparkGlassTheme.edgeLight,
                width: borderWidth,
              ),
              boxShadow: showShadow
                  ? [
                      BoxShadow(
                        color: SparkGlassTheme.edgeShadow,
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: content,
          ),
        ),
      );
    } else {
      surface = DecoratedBox(
        decoration: BoxDecoration(
          color: SparkGlassTheme.solidFallback,
          borderRadius: borderRadius,
          border: Border.all(
            color: borderColor ?? SparkTheme.ink.withValues(alpha: 0.08),
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: SparkGlassTheme.edgeShadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: content,
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: surface,
    );
  }
}
