import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import 'src/home_screen.dart';
import 'src/style.dart';

void main() {
  // In debug builds the marionette binding exposes the widget tree to the
  // marionette MCP tools (see README → "Driving the app").
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  runApp(const OpenFitApp());
}

/// The OpenFit warm-ink theme: bone text, signal lime and an editorial serif.
/// Shared with tests so they render the real thing.
ThemeData openFitTheme() {
  const tokens = FitTokens.dark;
  final scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: tokens.accent,
    onPrimary: tokens.onAccent,
    primaryContainer: const Color(0xFF2A3819),
    onPrimaryContainer: tokens.accent,
    secondary: tokens.sage,
    onSecondary: const Color(0xFF102018),
    secondaryContainer: const Color(0xFF1A2A21),
    onSecondaryContainer: tokens.sage,
    tertiary: tokens.ember,
    onTertiary: const Color(0xFF241407),
    tertiaryContainer: const Color(0xFF33220F),
    onTertiaryContainer: tokens.ember,
    error: tokens.danger,
    onError: const Color(0xFF2A0B06),
    errorContainer: const Color(0xFF3A1511),
    onErrorContainer: tokens.danger,
    surface: tokens.bg,
    onSurface: tokens.text,
    surfaceContainerLowest: tokens.bg,
    surfaceContainerLow: tokens.surface,
    surfaceContainer: tokens.raised,
    surfaceContainerHigh: tokens.high,
    surfaceContainerHighest: const Color(0xFF222A1E),
    onSurfaceVariant: tokens.muted,
    outline: tokens.lineStrong,
    outlineVariant: tokens.line,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: tokens.text,
    onInverseSurface: tokens.bg,
    inversePrimary: const Color(0xFF3F5B13),
  );

  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: kFitSans,
    scaffoldBackgroundColor: tokens.bg,
    canvasColor: tokens.bg,
    extensions: const [tokens],
    splashFactory: InkSparkle.splashFactory,
  );

  final text = base.textTheme.copyWith(
    displayLarge: TextStyle(
      fontFamily: kFitSerif,
      fontSize: 56,
      height: 0.98,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.6,
      color: tokens.text,
    ),
    displayMedium: TextStyle(
      fontFamily: kFitSerif,
      fontSize: 42,
      height: 1.0,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.1,
      color: tokens.text,
    ),
    displaySmall: TextStyle(
      fontFamily: kFitSerif,
      fontSize: 32,
      height: 1.05,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.6,
      color: tokens.text,
    ),
    headlineLarge: TextStyle(
      fontFamily: kFitSerif,
      fontSize: 30,
      height: 1.05,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.5,
      color: tokens.text,
    ),
    headlineMedium: TextStyle(
      fontFamily: kFitSerif,
      fontSize: 26,
      height: 1.1,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.4,
      color: tokens.text,
    ),
    headlineSmall: TextStyle(
      fontFamily: kFitSerif,
      fontSize: 22,
      height: 1.15,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
      color: tokens.text,
    ),
    titleLarge: TextStyle(
      fontFamily: kFitSans,
      fontSize: 17,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: tokens.text,
    ),
    titleMedium: TextStyle(
      fontFamily: kFitSans,
      fontSize: 15,
      height: 1.25,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: tokens.text,
    ),
    titleSmall: TextStyle(
      fontFamily: kFitSans,
      fontSize: 13,
      height: 1.25,
      fontWeight: FontWeight.w600,
      color: tokens.text,
    ),
    bodyLarge: TextStyle(
      fontFamily: kFitSans,
      fontSize: 15,
      height: 1.55,
      fontWeight: FontWeight.w400,
      color: tokens.text,
    ),
    bodyMedium: TextStyle(
      fontFamily: kFitSans,
      fontSize: 13.5,
      height: 1.5,
      fontWeight: FontWeight.w400,
      color: tokens.text,
    ),
    bodySmall: TextStyle(
      fontFamily: kFitSans,
      fontSize: 12,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: tokens.muted,
    ),
    labelLarge: TextStyle(
      fontFamily: kFitSans,
      fontSize: 12.5,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: tokens.text,
    ),
    labelMedium: TextStyle(
      fontFamily: kFitSans,
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.35,
      color: tokens.muted,
    ),
    labelSmall: TextStyle(
      fontFamily: kFitSans,
      fontSize: 10,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.3,
      color: tokens.dim,
    ),
  );

  final controlShape = RoundedRectangleBorder(borderRadius: Radii.control);
  final buttonStyle = ButtonStyle(
    shape: WidgetStatePropertyAll(controlShape),
    minimumSize: const WidgetStatePropertyAll(Size(48, 46)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.md),
    ),
    textStyle: WidgetStatePropertyAll(text.labelLarge),
    elevation: const WidgetStatePropertyAll(0),
    foregroundColor: WidgetStatePropertyAll(tokens.onAccent),
    backgroundColor: WidgetStatePropertyAll(tokens.accent),
  );

  return base.copyWith(
    textTheme: text,
    primaryTextTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: tokens.raised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.card,
        side: BorderSide(color: tokens.line),
      ),
    ),
    dividerTheme: DividerThemeData(color: tokens.line, space: 1, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: buttonStyle.copyWith(
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStatePropertyAll(tokens.text),
        side: WidgetStatePropertyAll(BorderSide(color: tokens.lineStrong)),
        textStyle: WidgetStatePropertyAll(text.labelLarge),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: buttonStyle.copyWith(
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStatePropertyAll(tokens.muted),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.sm),
        ),
        textStyle: WidgetStatePropertyAll(text.labelLarge),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        iconSize: 19,
        foregroundColor: tokens.muted,
        shape: const RoundedRectangleBorder(borderRadius: Radii.control),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: tokens.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Insets.md,
        vertical: Insets.md,
      ),
      hintStyle: TextStyle(color: tokens.dim, fontSize: 12.5),
      labelStyle: TextStyle(color: tokens.muted, fontSize: 12),
      floatingLabelStyle: TextStyle(color: tokens.accent, fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: Radii.control,
        borderSide: BorderSide(color: tokens.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: Radii.control,
        borderSide: BorderSide(color: tokens.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: Radii.control,
        borderSide: BorderSide(color: tokens.accent, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: Radii.control,
        borderSide: BorderSide(color: tokens.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: Radii.control,
        borderSide: BorderSide(color: tokens.danger, width: 1.2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: tokens.accent.withValues(alpha: 0.12),
      secondarySelectedColor: tokens.accent.withValues(alpha: 0.12),
      disabledColor: tokens.surface,
      side: BorderSide(color: tokens.line),
      shape: const RoundedRectangleBorder(borderRadius: Radii.pillRadius),
      labelStyle: text.labelMedium,
      secondaryLabelStyle: text.labelMedium,
      checkmarkColor: tokens.accent,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: Radii.control),
        ),
        side: WidgetStatePropertyAll(BorderSide(color: tokens.line)),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? tokens.accent.withValues(alpha: 0.12)
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? tokens.accent
              : tokens.muted,
        ),
        textStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: tokens.surface,
      indicatorColor: tokens.accent.withValues(alpha: 0.14),
      height: 66,
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(text.labelSmall),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? tokens.accent
              : tokens.dim,
          size: 22,
        ),
      ),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 3,
      activeTrackColor: tokens.accent,
      inactiveTrackColor: tokens.line,
      thumbColor: tokens.accent,
      overlayColor: tokens.accent.withValues(alpha: 0.12),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      activeTickMarkColor: tokens.onAccent,
      inactiveTickMarkColor: tokens.dim,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? tokens.onAccent
            : tokens.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? tokens.accent : tokens.line,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: tokens.high,
      contentTextStyle: text.bodySmall!.copyWith(color: tokens.text),
      shape: const RoundedRectangleBorder(borderRadius: Radii.control),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: tokens.raised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.xxl),
        side: BorderSide(color: tokens.line),
      ),
      titleTextStyle: text.headlineSmall,
      contentTextStyle: text.bodyMedium,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(tokens.raised),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: Radii.control),
        ),
        side: WidgetStatePropertyAll(BorderSide(color: tokens.line)),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: tokens.muted,
      textColor: tokens.text,
      titleTextStyle: text.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
      subtitleTextStyle: text.bodySmall,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: tokens.accent,
      linearTrackColor: tokens.line,
      circularTrackColor: tokens.line,
      linearMinHeight: 4,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: tokens.high,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: tokens.line),
      ),
      textStyle: text.bodySmall!.copyWith(color: tokens.text, fontSize: 11),
      waitDuration: const Duration(milliseconds: 350),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: const WidgetStatePropertyAll(4),
      radius: const Radius.circular(2),
      thumbColor: WidgetStatePropertyAll(
        tokens.lineStrong.withValues(alpha: 0.9),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      side: BorderSide(color: tokens.lineStrong),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? tokens.accent
            : Colors.transparent,
      ),
      checkColor: WidgetStatePropertyAll(tokens.onAccent),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: tokens.raised,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: Radii.control),
      textStyle: text.bodyMedium,
    ),
  );
}

class OpenFitApp extends StatelessWidget {
  const OpenFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenFit',
      debugShowCheckedModeBanner: false,
      theme: openFitTheme(),
      home: const HomeScreen(),
    );
  }
}
