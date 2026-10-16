import 'package:flutter/material.dart';

/// The monospace family used for code, paths, and terminal chrome.
///
/// Menlo ships with macOS; [kMonoFontFallback] covers SF Mono and the
/// platform's generic monospace (also used on the web build).
const String kMonoFontFamily = 'Menlo';

/// Fallbacks for the monospace stack, tried in order.
const List<String> kMonoFontFallback = <String>['SF Mono', 'monospace'];

/// Shared monospace style; call `kMonoTextStyle.copyWith(...)` to adjust.
const TextStyle kMonoTextStyle = TextStyle(
  fontFamily: kMonoFontFamily,
  fontFamilyFallback: kMonoFontFallback,
);

/// Builds the cockpit themes (dark and light) with shared shape and density.
ThemeData buildCockpitTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7C6CF0),
    brightness: brightness,
    surface: dark ? const Color(0xFF121317) : const Color(0xFFF7F7FA),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark
        ? const Color(0xFF0C0D11)
        : const Color(0xFFEFEFF4),
    visualDensity: VisualDensity.compact,
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: dark ? 0.35 : 0.6),
      thickness: 1,
      space: 1,
    ),
    tooltipTheme: const TooltipThemeData(
      waitDuration: Duration(milliseconds: 350),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(false),
      thickness: WidgetStateProperty.all(7),
      radius: const Radius.circular(4),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

/// Panel background colors used across the workbench.
extension CockpitPalette on ThemeData {
  Color get panelBackground => colorScheme.surfaceContainerLow;

  Color get railBackground => colorScheme.surfaceContainer;

  Color get codeBackground => brightness == Brightness.dark
      ? const Color(0xFF14151A)
      : const Color(0xFFF2F2F6);

  Color get codeForeground => brightness == Brightness.dark
      ? const Color(0xFFD8DBE6)
      : const Color(0xFF23242B);
}
