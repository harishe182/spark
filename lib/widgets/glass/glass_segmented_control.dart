import 'package:flutter/cupertino.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';

/// iOS sliding segmented control with Spark-tuned neutral chrome.
class GlassSegmentedControl<T extends Object> extends StatelessWidget {
  const GlassSegmentedControl({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Map<T, Widget> children;
  final T groupValue;
  final ValueChanged<T> onValueChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final labelStyle = CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: SparkTheme.label,
        );

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: CupertinoSlidingSegmentedControl<T>(
              groupValue: groupValue,
              backgroundColor: SparkTheme.groupedBackground,
              thumbColor: SparkTheme.secondaryGroupedBackground,
              padding: const EdgeInsets.all(3),
              children: children.map(
                (key, child) => MapEntry(
                  key,
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: DefaultTextStyle(
                      style: labelStyle,
                      textAlign: TextAlign.center,
                      child: child,
                    ),
                  ),
                ),
              ),
              onValueChanged: (value) {
                if (value == null) return;
                SparkHaptics.selection();
                onValueChanged(value);
              },
            ),
          );
        },
      ),
    );
  }
}
