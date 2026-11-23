import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';

/// iOS Settings-style row with a trailing [CupertinoSwitch].
class GlassToggleRow extends StatelessWidget {
  const GlassToggleRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: hasSubtitle ? 14 : 12,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: hasSubtitle ? 52 : 44),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: enabled
                              ? SparkTheme.label
                              : SparkTheme.tertiaryLabel,
                        ),
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
            const SizedBox(width: 12),
            CupertinoSwitch(
              value: value,
              activeTrackColor: SparkTheme.sparkAmber,
              onChanged: enabled
                  ? (v) {
                      SparkHaptics.selection();
                      onChanged(v);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
