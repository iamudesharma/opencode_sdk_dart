import 'package:flutter/material.dart';

/// Monospace family used for code, paths, and identifiers.
///
/// Menlo ships with macOS; the fallbacks cover the other platforms and the
/// generic `monospace` keyword the web engine understands.
const String kMonoFontFamily = 'Menlo';

/// Fallback families for [kMonoFontFamily], tried in order.
const List<String> kMonoFontFallback = <String>[
  'SF Mono',
  'SFMono-Regular',
  'Monaco',
  'Consolas',
  'Liberation Mono',
  'DejaVu Sans Mono',
  'monospace',
];

/// A monospace [TextStyle] using the shared fallback stack.
TextStyle monoStyle({
  double? fontSize,
  double? height,
  Color? color,
  FontWeight? fontWeight,
  TextDecoration? decoration,
}) {
  return TextStyle(
    fontFamily: kMonoFontFamily,
    fontFamilyFallback: kMonoFontFallback,
    fontSize: fontSize,
    height: height,
    color: color,
    fontWeight: fontWeight,
    decoration: decoration,
  );
}

/// Applies the monospace stack to an existing [base] style.
TextStyle monoCopy(TextStyle base, {double? fontSize, Color? color}) {
  return base.copyWith(
    fontFamily: kMonoFontFamily,
    fontFamilyFallback: kMonoFontFallback,
    fontSize: fontSize,
    color: color,
  );
}

/// Builds the app theme for [brightness]; the dark variant is the default.
///
/// [fontFamily] overrides the default text family. Production passes null so
/// the platform font is used; preview tests pass a family they have loaded
/// with real system fonts.
ThemeData buildAppTheme(Brightness brightness, {String? fontFamily}) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7C6CF0),
    brightness: brightness,
    surface: dark ? const Color(0xFF121317) : const Color(0xFFF8F8FC),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        dark ? const Color(0xFF0E0F13) : const Color(0xFFF4F4F9),
    fontFamily: fontFamily,
    visualDensity: VisualDensity.compact,
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.35),
      thickness: 1,
    ),
    tooltipTheme:
        const TooltipThemeData(waitDuration: Duration(milliseconds: 400)),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(false),
      thickness: WidgetStateProperty.all(7),
      radius: const Radius.circular(4),
    ),
  );
}
