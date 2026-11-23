import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Visual theme. Facilitator screens use neutral iOS-style chrome; child-facing
/// screens keep large touch targets and warm accents for Spark branding.
///
/// Typography uses the platform system font — San Francisco on Apple devices.
class SparkTheme {
  SparkTheme._();

  // Spark brand accents (actions, mascot, CTAs).
  static const Color sparkYellow = Color(0xFFFFC107);
  static const Color sparkAmber = Color(0xFFFF9800);
  static const Color skyBlue = Color(0xFF4FC3F7);
  static const Color leafGreen = Color(0xFF66BB6A);
  static const Color coral = Color(0xFFFF7043);

  // Legacy ink — prefer [label] for new UI.
  static const Color ink = Color(0xFF37474F);
  static const Color cream = Color(0xFFFFF8E1);

  // iOS-style neutral chrome.
  static const Color label = Color(0xFF000000);
  static const Color secondaryLabel = Color(0x993C3C43);
  static const Color tertiaryLabel = Color(0x4D3C3C43);
  static const Color groupedBackground = Color(0xFFF2F2F7);
  static const Color secondaryGroupedBackground = Color(0xFFFFFFFF);
  static const Color separator = Color(0xFFC6C6C8);

  /// San Francisco on iOS/macOS; each platform's default elsewhere.
  static String? get _fontFamily {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '.AppleSystemUIFont';
      default:
        return null;
    }
  }

  static TextStyle _text({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    List<FontFeature>? fontFeatures,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      fontFeatures: fontFeatures,
    );
  }

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: sparkAmber,
        primary: sparkAmber,
        secondary: skyBlue,
        surface: groupedBackground,
        onSurface: label,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
    );

    final textTheme = base.textTheme.apply(
      fontFamily: _fontFamily,
      bodyColor: label,
      displayColor: label,
    ).copyWith(
      displayLarge: _text(fontSize: 34, fontWeight: FontWeight.w700, color: label),
      headlineMedium: _text(fontSize: 22, fontWeight: FontWeight.w600, color: label),
      titleLarge: _text(fontSize: 17, fontWeight: FontWeight.w600, color: label),
      titleMedium: _text(fontSize: 17, fontWeight: FontWeight.w400, color: label),
      bodyLarge: _text(fontSize: 17, fontWeight: FontWeight.w400, color: label),
      bodyMedium: _text(fontSize: 15, fontWeight: FontWeight.w400, color: label),
      labelLarge: _text(fontSize: 17, fontWeight: FontWeight.w600, color: label),
      labelSmall: _text(fontSize: 13, fontWeight: FontWeight.w400, color: secondaryLabel),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: _text(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: label,
        ),
      ),
      cardTheme: CardThemeData(
        color: secondaryGroupedBackground.withValues(alpha: 0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: separator.withValues(alpha: 0.35)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: secondaryGroupedBackground.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 64),
          textStyle: _text(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: _text(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryGroupedBackground.withValues(alpha: 0.75),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: separator.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: separator.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: sparkAmber, width: 2),
        ),
        labelStyle: _text(color: label),
        hintStyle: _text(color: tertiaryLabel),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: groupedBackground,
        selectedColor: sparkAmber.withValues(alpha: 0.25),
        labelStyle: _text(color: label, fontSize: 13),
        side: BorderSide(color: separator.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(
        color: separator,
        thickness: 0.5,
      ),
    );
  }

  static CupertinoThemeData cupertino(BuildContext context) {
    return CupertinoThemeData(
      primaryColor: sparkAmber,
      barBackgroundColor: Colors.transparent,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: CupertinoTextThemeData(
        primaryColor: label,
        textStyle: _text(fontSize: 17, color: label),
        actionTextStyle: _text(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: sparkAmber,
        ),
        navTitleTextStyle: _text(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: label,
        ),
        navLargeTitleTextStyle: _text(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: label,
        ),
        tabLabelTextStyle: _text(fontSize: 10, color: secondaryLabel),
      ),
    );
  }

  /// Section header style for grouped lists (iOS Settings footnote).
  static TextStyle get sectionHeader => _text(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondaryLabel,
      );

  /// Large, friendly button text style for child-facing buttons.
  static TextStyle get childButtonText => _text(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      );
}
