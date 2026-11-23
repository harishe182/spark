import 'package:flutter/services.dart';

/// Light haptic feedback for primary taps and selections.
class SparkHaptics {
  SparkHaptics._();

  static void tap() {
    HapticFeedback.lightImpact();
  }

  static void selection() {
    HapticFeedback.selectionClick();
  }
}
