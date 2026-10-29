import 'package:flutter/material.dart';

/// The UI sans bundled with the cockpit (macOS, web and tests).
const String kSansFontFamily = 'InstrumentSans';

/// Fallbacks for the UI sans stack.
const List<String> kSansFontFallback = <String>[
  'SF Pro Text',
  'Segoe UI',
  'Roboto',
  'sans-serif',
];

/// The monospace family used for code, paths, and terminal chrome.
const String kMonoFontFamily = 'JetBrainsMono';

/// Fallbacks for the monospace stack, tried in order.
const List<String> kMonoFontFallback = <String>[
  'Menlo',
  'SF Mono',
  'monospace',
];

/// Shared monospace style; call `kMonoTextStyle.copyWith(...)` to adjust.
const TextStyle kMonoTextStyle = TextStyle(
  fontFamily: kMonoFontFamily,
  fontFamilyFallback: kMonoFontFallback,
  fontFeatures: [FontFeature.tabularFigures()],
);

/// Builds the cockpit themes (dark and light) with shared shape and density.
ThemeData buildCockpitTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: dark ? const Color(0xFFA8C3FF) : const Color(0xFF2E4FC4),
    onPrimary: dark ? const Color(0xFF0A1428) : const Color(0xFFFFFFFF),
    primaryContainer: dark ? const Color(0xFF1B2A4A) : const Color(0xFFDDE6FF),
    onPrimaryContainer: dark
        ? const Color(0xFFDCE7FF)
        : const Color(0xFF0A1B4A),
    secondary: dark ? const Color(0xFF7CE3C8) : const Color(0xFF0F766E),
    onSecondary: dark ? const Color(0xFF062A23) : const Color(0xFFFFFFFF),
    secondaryContainer: dark
        ? const Color(0xFF103A32)
        : const Color(0xFFD2F3EC),
    onSecondaryContainer: dark
        ? const Color(0xFFC8F7EB)
        : const Color(0xFF052E2A),
    tertiary: dark ? const Color(0xFFF2C879) : const Color(0xFF9A5B00),
    onTertiary: dark ? const Color(0xFF2B1D05) : const Color(0xFFFFFFFF),
    tertiaryContainer: dark ? const Color(0xFF3A2A0D) : const Color(0xFFFFE7C2),
    onTertiaryContainer: dark
        ? const Color(0xFFFFE1AC)
        : const Color(0xFF2E1B00),
    error: dark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
    onError: dark ? const Color(0xFF2B0A07) : const Color(0xFFFFFFFF),
    errorContainer: dark ? const Color(0xFF3B1513) : const Color(0xFFF9DEDC),
    onErrorContainer: dark ? const Color(0xFFFFD9D6) : const Color(0xFF410E0B),
    surface: dark ? const Color(0xFF0A0B0D) : const Color(0xFFF5F4EF),
    onSurface: dark ? const Color(0xFFE9ECF2) : const Color(0xFF1A1B1E),
    surfaceContainerLowest: dark
        ? const Color(0xFF07080A)
        : const Color(0xFFFFFFFF),
    surfaceContainerLow: dark
        ? const Color(0xFF0E1014)
        : const Color(0xFFFBFAF6),
    surfaceContainer: dark ? const Color(0xFF12151A) : const Color(0xFFF2F0E9),
    surfaceContainerHigh: dark
        ? const Color(0xFF171B21)
        : const Color(0xFFECE9E1),
    surfaceContainerHighest: dark
        ? const Color(0xFF1D222A)
        : const Color(0xFFE4E0D6),
    onSurfaceVariant: dark ? const Color(0xFFA2A9B6) : const Color(0xFF65686F),
    outline: dark ? const Color(0xFF3A424F) : const Color(0xFFB9B4A8),
    outlineVariant: dark ? const Color(0xFF242A33) : const Color(0xFFDED9CE),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: dark ? const Color(0xFFE9ECF2) : const Color(0xFF1A1B1E),
    onInverseSurface: dark ? const Color(0xFF0A0B0D) : const Color(0xFFF5F4EF),
    inversePrimary: dark ? const Color(0xFF2E4FC4) : const Color(0xFFA8C3FF),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    fontFamily: kSansFontFamily,
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,
    visualDensity: VisualDensity.compact,
    splashFactory: InkSparkle.splashFactory,
  );

  final text = base.textTheme.copyWith(
    displayLarge: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 34,
      height: 1.05,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.8,
      color: scheme.onSurface,
    ),
    displayMedium: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 28,
      height: 1.1,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.6,
      color: scheme.onSurface,
    ),
    displaySmall: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 24,
      height: 1.15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
      color: scheme.onSurface,
    ),
    headlineMedium: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 20,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: scheme.onSurface,
    ),
    headlineSmall: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 17,
      height: 1.25,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: scheme.onSurface,
    ),
    titleLarge: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 15,
      height: 1.25,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: scheme.onSurface,
    ),
    titleMedium: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 13.5,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    titleSmall: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 12.5,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    bodyLarge: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 14,
      height: 1.55,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
    ),
    bodyMedium: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 13,
      height: 1.55,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
    ),
    bodySmall: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 11.5,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant,
    ),
    labelLarge: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 11.5,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: scheme.onSurface,
    ),
    labelMedium: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 10.5,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: scheme.onSurfaceVariant,
    ),
    labelSmall: TextStyle(
      fontFamily: kSansFontFamily,
      fontSize: 9.5,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      color: scheme.outline,
    ),
  );

  return base.copyWith(
    textTheme: text,
    primaryTextTheme: text,
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: dark ? 0.75 : 1),
      thickness: 1,
      space: 1,
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 350),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      textStyle: text.bodySmall!.copyWith(
        color: scheme.onSurface,
        fontSize: 11,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: const WidgetStatePropertyAll(false),
      thickness: const WidgetStatePropertyAll(5),
      radius: const Radius.circular(3),
      thumbColor: WidgetStatePropertyAll(scheme.outline.withValues(alpha: 0.6)),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(32, 32),
        iconSize: 17,
        foregroundColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: text.labelLarge,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: scheme.outlineVariant),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: text.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      hintStyle: text.bodySmall!.copyWith(color: scheme.outline),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.primary, width: 1.2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      side: BorderSide(color: scheme.outlineVariant),
      shape: const StadiumBorder(),
      labelStyle: text.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      titleTextStyle: text.headlineSmall,
      contentTextStyle: text.bodyMedium,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      textStyle: text.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.surfaceContainerHigh,
      contentTextStyle: text.bodySmall!.copyWith(color: scheme.onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    listTileTheme: ListTileThemeData(
      dense: true,
      iconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      titleTextStyle: text.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
      subtitleTextStyle: text.bodySmall,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.outlineVariant,
      circularTrackColor: Colors.transparent,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: BorderSide(color: scheme.outline),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : Colors.transparent,
      ),
      checkColor: WidgetStatePropertyAll(scheme.onPrimary),
    ),
  );
}

/// Panel palette used across the workbench.
extension CockpitPalette on ThemeData {
  /// The main panel surface.
  Color get panelBackground => colorScheme.surfaceContainerLow;

  /// The activity rail surface.
  Color get railBackground => colorScheme.surface;

  /// The top bar and status bar chrome.
  Color get chromeBackground => colorScheme.surface;

  /// Raised cards and floating controls.
  Color get surfaceRaised => colorScheme.surfaceContainer;

  /// The hairline used for panel borders.
  Color get hairline => colorScheme.outlineVariant;

  /// The single signal accent.
  Color get accent => colorScheme.primary;

  /// A soft accent wash for selected rows.
  Color get accentSoft => colorScheme.primary.withValues(alpha: 0.12);

  /// Success / connected state.
  Color get success => colorScheme.secondary;

  /// Warning / queued state.
  Color get warning => colorScheme.tertiary;

  /// The code block background.
  Color get codeBackground => brightness == Brightness.dark
      ? const Color(0xFF0B0E12)
      : const Color(0xFFF0EEE7);

  /// The code block foreground.
  Color get codeForeground => brightness == Brightness.dark
      ? const Color(0xFFD7DCE6)
      : const Color(0xFF23252B);

  /// The uppercase micro-label style used above panels and metadata.
  TextStyle get microLabel => textTheme.labelSmall!.copyWith(
    fontSize: 9,
    letterSpacing: 1.4,
    fontWeight: FontWeight.w600,
    color: colorScheme.onSurfaceVariant,
  );
}
