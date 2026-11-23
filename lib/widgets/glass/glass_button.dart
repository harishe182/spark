import 'package:flutter/material.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';
import 'glass_surface.dart';

/// Glass-styled button with large touch targets for child-facing actions.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = SparkTheme.sparkAmber,
    this.foregroundColor = Colors.white,
    this.minimumSize = const Size(140, 64),
    this.stadium = false,
    this.tintOpacity,
    this.blurSigma,
    this.elevated = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final Color foregroundColor;
  final Size minimumSize;
  final bool stadium;
  final double? tintOpacity;
  final double? blurSigma;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final radius = stadium
        ? const BorderRadius.all(Radius.circular(999))
        : const BorderRadius.all(Radius.circular(20));

    final Widget face = elevated ? _elevatedFace(radius) : _glassFace(radius);

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed == null
            ? null
            : () {
                SparkHaptics.tap();
                onPressed!();
              },
        borderRadius: radius,
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: elevated
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(borderRadius: radius, child: face),
              )
            : face,
      ),
    );

    return Opacity(opacity: onPressed == null ? 0.5 : 1, child: button);
  }

  /// Uniform orange fill with a thin top shine — no backdrop blur streaks.
  Widget _elevatedFace(BorderRadius radius) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(color, Colors.white, 0.1)!,
            color,
            Color.lerp(color, Colors.black, 0.06)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 1,
            left: 12,
            right: 12,
            height: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
          ),
          _buttonContent(radius),
        ],
      ),
    );
  }

  Widget _glassFace(BorderRadius radius) {
    return GlassSurface(
      borderRadius: radius,
      tintColor: color.withValues(alpha: tintOpacity ?? 0.85),
      blurSigma: blurSigma ?? 10,
      borderColor: color.withValues(alpha: 0.55),
      child: _buttonContent(radius),
    );
  }

  Widget _buttonContent(BorderRadius radius) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minimumSize.width,
        minHeight: minimumSize.height,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: stadium ? 28 : 20,
          vertical: stadium ? 16 : 12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: foregroundColor, size: stadium ? 26 : 28),
              if (label.isNotEmpty) SizedBox(width: stadium ? 10 : 8),
            ],
            if (label.isNotEmpty)
              Text(
                label,
                style: SparkTheme.childButtonText.copyWith(
                  color: foregroundColor,
                  fontSize: icon != null ? (stadium ? 18 : 22) : 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact pill button sized to fit inside [GlassAppBar] / toolbars.
class GlassBarButton extends StatelessWidget {
  const GlassBarButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = SparkTheme.leafGreen,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final bool loading;

  static const _radius = BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null && !loading ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading
              ? null
              : onPressed == null
                  ? null
                  : () {
                      SparkHaptics.tap();
                      onPressed!();
                    },
          borderRadius: _radius,
          child: GlassSurface(
            borderRadius: _radius,
            blurSigma: 12,
            tintColor: color.withValues(alpha: 0.88),
            borderColor: color.withValues(alpha: 0.45),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else if (icon != null) ...[
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: SparkTheme.childButtonText.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact circular glass icon button for toolbars.
class GlassBarIconButton extends StatelessWidget {
  const GlassBarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = SparkTheme.coral,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed == null
            ? null
            : () {
                SparkHaptics.tap();
                onPressed!();
              },
          customBorder: const CircleBorder(),
          child: GlassSurface(
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            blurSigma: 12,
            tintColor: color.withValues(alpha: 0.2),
            borderColor: color.withValues(alpha: 0.45),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Tonal glass button for secondary actions.
class GlassTonalButton extends StatelessWidget {
  const GlassTonalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      color: SparkTheme.skyBlue,
      minimumSize: const Size(100, 48),
    );
  }
}
