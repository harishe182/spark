import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// iOS Settings-style list row with optional subtitle, trailing, and chevron.
class GlassListRow extends StatelessWidget {
  const GlassListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.showChevron = false,
    this.onTap,
    this.enabled = true,
    this.emphasized = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;
  final bool enabled;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null;
    final titleStyle = emphasized
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: enabled ? SparkTheme.label : SparkTheme.tertiaryLabel,
            )
        : Theme.of(context).textTheme.titleMedium?.copyWith(
              color: enabled ? SparkTheme.label : SparkTheme.tertiaryLabel,
            );
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: hasSubtitle ? 14 : 12,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: hasSubtitle ? 52 : 44),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: titleStyle,
                  ),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
            if (showChevron) ...[
              const SizedBox(width: 6),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 16,
                color: SparkTheme.tertiaryLabel,
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: content,
      ),
    );
  }
}

/// Colored circle icon used for session and list accents.
class GlassAccentIcon extends StatelessWidget {
  const GlassAccentIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.iconSize = 20,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: iconSize),
    );
  }
}
