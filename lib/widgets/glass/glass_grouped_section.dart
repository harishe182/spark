import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'glass_surface.dart';

/// iOS Settings-style grouped section with optional header and footer.
class GlassGroupedSection extends StatelessWidget {
  const GlassGroupedSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
    this.tintColor,
    this.light = false,
  });

  final String? header;
  final String? footer;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;
  final Color? tintColor;
  final bool light;

  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
              child: Text(
                header!.toUpperCase(),
                style: SparkTheme.sectionHeader,
              ),
            ),
          GlassSurface(
            borderRadius: _radius,
            blurSigma: light ? 14 : 18,
            tintOpacity: light ? 0.72 : 0.78,
            tintColor: tintColor ??
                SparkTheme.secondaryGroupedBackground.withValues(alpha: 0.85),
            borderColor: tintColor != null
                ? tintColor!.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.55),
            showShadow: tintColor != null,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _separatedChildren(),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 10, right: 4),
              child: Text(
                footer!,
                style: SparkTheme.sectionHeader,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _separatedChildren() {
    if (children.isEmpty) return [];
    final result = <Widget>[children.first];
    for (var i = 1; i < children.length; i++) {
      result.add(
        Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 20,
          color: SparkTheme.separator.withValues(alpha: 0.6),
        ),
      );
      result.add(children[i]);
    }
    return result;
  }
}
