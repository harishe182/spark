import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';
import 'glass_theme.dart';

/// Presents a glass-styled modal sheet (iOS bottom sheet pattern).
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  return showCupertinoModalPopup<T>(
    context: context,
    barrierDismissible: isDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (context) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: builder(context),
          ),
        ),
      );
    },
  );
}

/// Standard glass sheet panel with drag handle and rounded top corners.
class GlassSheetPanel extends StatelessWidget {
  const GlassSheetPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 20),
    this.fillHeight = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool fillHeight;

  static const _radius = BorderRadius.vertical(top: Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ClipRRect(
        borderRadius: _radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: SparkGlassTheme.cloudedBlur,
            sigmaY: SparkGlassTheme.cloudedBlur,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: SparkTheme.secondaryGroupedBackground
                  .withValues(alpha: SparkGlassTheme.cloudedTintOpacity),
              borderRadius: _radius,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.65),
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: padding,
              child: Column(
                mainAxisSize:
                    fillHeight ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16, top: 4),
                      decoration: BoxDecoration(
                        color: SparkTheme.separator.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  if (fillHeight) Expanded(child: child) else child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary filled action for sheet footers (iOS-style).
class GlassSheetPrimaryButton extends StatelessWidget {
  const GlassSheetPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.color = SparkTheme.sparkAmber,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(vertical: 14),
        borderRadius: BorderRadius.circular(12),
        color: color,
        disabledColor: color.withValues(alpha: 0.45),
        onPressed: loading || onPressed == null
            ? null
            : () {
                SparkHaptics.tap();
                onPressed!();
              },
        child: loading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
