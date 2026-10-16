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

/// The OpenFit carbon-and-emerald dark theme, shared with tests so they
/// render the real thing.
ThemeData openFitTheme() {
  const emerald = Color(0xFF3ED598);
  const carbon = Color(0xFF101418);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: emerald,
        brightness: Brightness.dark,
      ).copyWith(
        surface: carbon,
        surfaceContainerLowest: const Color(0xFF0B0E12),
        surfaceContainerLow: const Color(0xFF141A20),
        surfaceContainer: const Color(0xFF182028),
        surfaceContainerHigh: const Color(0xFF1E2731),
        surfaceContainerHighest: const Color(0xFF243039),
        outlineVariant: const Color(0xFF2C3742),
        outline: const Color(0xFF3C4A57),
        primary: emerald,
        onPrimary: const Color(0xFF00301C),
      );

  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  const controlShape = RoundedRectangleBorder(borderRadius: Radii.control);
  final buttonStyle = ButtonStyle(
    shape: const WidgetStatePropertyAll(controlShape),
    minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.md),
    ),
    textStyle: WidgetStatePropertyAll(base.textTheme.labelLarge),
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF0B0E12),
    canvasColor: carbon,
    appBarTheme: AppBarTheme(
      backgroundColor: carbon,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.card,
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.5),
      space: 1,
      thickness: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyle),
    textButtonTheme: TextButtonThemeData(
      style: buttonStyle.copyWith(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.sm),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        iconSize: 20,
        shape: const RoundedRectangleBorder(borderRadius: Radii.control),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: scheme.surfaceContainerHigh.withValues(alpha: 0.55),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Insets.md,
        vertical: Insets.md,
      ),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: Radii.control,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: Radii.control,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: Radii.control,
        borderSide: BorderSide(color: scheme.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: Radii.control,
        borderSide: BorderSide(color: scheme.error),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      selectedColor: scheme.primary.withValues(alpha: 0.22),
      secondarySelectedColor: scheme.primary.withValues(alpha: 0.22),
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      shape: const RoundedRectangleBorder(borderRadius: Radii.pillRadius),
      labelStyle: base.textTheme.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: Insets.sm, vertical: 2),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: Radii.control),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary.withValues(alpha: 0.18)
              : null,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
        textStyle: WidgetStatePropertyAll(base.textTheme.labelMedium),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: carbon,
      indicatorColor: scheme.primary.withValues(alpha: 0.18),
      height: 68,
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(base.textTheme.labelSmall),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
          size: 24,
        ),
      ),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 4,
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.surfaceContainerHighest,
      thumbColor: scheme.primary,
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary.withValues(alpha: 0.35)
            : scheme.surfaceContainerHighest,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.surfaceContainerHighest,
      contentTextStyle: base.textTheme.bodySmall,
      shape: const RoundedRectangleBorder(borderRadius: Radii.control),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      titleTextStyle: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: Radii.control),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      titleTextStyle: base.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      subtitleTextStyle: base.textTheme.bodySmall?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
      linearMinHeight: 6,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      textStyle: base.textTheme.bodySmall,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: const WidgetStatePropertyAll(6),
      radius: const Radius.circular(3),
      thumbColor: WidgetStatePropertyAll(
        scheme.outline.withValues(alpha: 0.6),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(color: scheme.outline),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(borderRadius: Radii.control),
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
