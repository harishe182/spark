import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'glass_surface.dart';
import 'glass_theme.dart';

/// Glass-styled text field for child and facilitator forms.
class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.maxLines = 1,
    this.onSubmitted,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? hintText;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      blurSigma: SparkGlassTheme.lightBlur,
      tintOpacity: 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: SparkTheme.ink,
            ),
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
