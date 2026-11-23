import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';
import 'glass_surface.dart';

/// Glass app bar with transparent scaffold integration.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  Widget? _defaultLeading(BuildContext context) {
    if (!automaticallyImplyLeading || !Navigator.canPop(context)) {
      return null;
    }
    return GlassNavBackButton(onPressed: () => Navigator.maybePop(context));
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = CupertinoTheme.of(context).textTheme.navTitleTextStyle;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: GlassSurface(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          blurSigma: 24,
          tintOpacity: 0.72,
          tintColor: Colors.white.withValues(alpha: 0.78),
          borderColor: Colors.white.withValues(alpha: 0.55),
          showShadow: true,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: leading ?? _defaultLeading(context),
                ),
                Expanded(
                  child: title != null
                      ? DefaultTextStyle(
                          style: titleStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          child: title!,
                        )
                      : const SizedBox.shrink(),
                ),
                if (actions != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _spacedActions(actions!),
                    ),
                  )
                else
                  const SizedBox(width: 44),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _spacedActions(List<Widget> items) {
    if (items.isEmpty) return items;
    final result = <Widget>[items.first];
    for (var i = 1; i < items.length; i++) {
      result.add(const SizedBox(width: 2));
      result.add(items[i]);
    }
    return result;
  }
}

/// iOS-style back chevron for glass navigation bars.
class GlassNavBackButton extends StatelessWidget {
  const GlassNavBackButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.only(left: 4, right: 8),
      minimumSize: Size.zero,
      onPressed: onPressed == null
          ? null
          : () {
              SparkHaptics.tap();
              onPressed!();
            },
      child: Icon(
        CupertinoIcons.back,
        size: 26,
        color: onPressed == null
            ? SparkTheme.tertiaryLabel
            : SparkTheme.sparkAmber,
      ),
    );
  }
}

/// Lightweight text + icon action for nav bar trailing slots.
class GlassNavAction extends StatelessWidget {
  const GlassNavAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = SparkTheme.sparkAmber,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: Size.zero,
      onPressed: onPressed == null
          ? null
          : () {
              SparkHaptics.tap();
              onPressed!();
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: color),
            if (label.isNotEmpty) const SizedBox(width: 3),
          ],
          if (label.isNotEmpty)
            Text(
              label,
              style: CupertinoTheme.of(context).textTheme.actionTextStyle.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
        ],
      ),
    );
  }
}

/// Minimal icon-only nav bar action (no glass chrome).
class GlassNavIconAction extends StatelessWidget {
  const GlassNavIconAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = SparkTheme.secondaryLabel,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: Size.zero,
      onPressed: onPressed == null
          ? null
          : () {
              SparkHaptics.tap();
              onPressed!();
            },
      child: Icon(icon, size: 22, color: color),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
