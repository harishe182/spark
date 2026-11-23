import 'package:flutter/material.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';
import 'glass_card.dart';

/// Shows a glass-styled dialog.
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: builder(ctx),
      );
    },
  );
}

/// Glass dialog content panel — wrap your dialog body with this.
class GlassDialogContent extends StatelessWidget {
  const GlassDialogContent({
    super.key,
    required this.child,
    this.maxWidth = 320,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      clouded: true,
      padding: padding,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// iOS-style liquid glass alert with split action buttons.
class GlassActionDialog extends StatelessWidget {
  const GlassActionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
  });

  final String title;
  final String message;
  final List<GlassDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    return GlassDialogContent(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        height: 1.35,
                        color: SparkTheme.secondaryLabel,
                      ),
                ),
              ],
            ),
          ),
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: SparkTheme.separator.withValues(alpha: 0.65),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0)
                    VerticalDivider(
                      width: 0.5,
                      thickness: 0.5,
                      color: SparkTheme.separator.withValues(alpha: 0.65),
                    ),
                  Expanded(
                    child: _ActionButton(
                      action: actions[i],
                      index: i,
                      count: actions.length,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GlassDialogAction {
  const GlassDialogAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.color,
  });

  final String label;
  final VoidCallback onPressed;
  final bool destructive;
  final Color? color;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.action,
    required this.index,
    required this.count,
  });

  final GlassDialogAction action;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textColor = action.color ??
        (action.destructive ? SparkTheme.coral : SparkTheme.sparkAmber);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          SparkHaptics.tap();
          action.onPressed();
        },
        borderRadius: BorderRadius.only(
          bottomLeft: index == 0 ? const Radius.circular(20) : Radius.zero,
          bottomRight:
              index == count - 1 ? const Radius.circular(20) : Radius.zero,
        ),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              action.label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass-styled alert with title, content, and action buttons.
class GlassAlertDialog extends StatelessWidget {
  const GlassAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return GlassDialogContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            DefaultTextStyle(
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              child: title!,
            ),
            const SizedBox(height: 12),
          ],
          if (content != null) ...[
            DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyLarge!,
              child: content!,
            ),
            const SizedBox(height: 20),
          ],
          if (actions != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
        ],
      ),
    );
  }
}
