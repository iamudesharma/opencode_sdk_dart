/// The OpenFit design language: warm ink surfaces, bone text, one signal lime,
/// an editorial serif for display and a mono face for numbers.
library;

import 'package:flutter/material.dart';

import 'attachments.dart';

/// Bundled UI sans.
const String kFitSans = 'InstrumentSans';

/// Bundled editorial display serif.
const String kFitSerif = 'Fraunces';

/// Bundled mono for metrics, ranges and timestamps.
const String kFitMono = 'JetBrainsMono';

/// Monospace text with tabular figures.
const TextStyle kFitMonoStyle = TextStyle(
  fontFamily: kFitMono,
  fontFeatures: [FontFeature.tabularFigures()],
);

/// The spacing scale, in logical pixels.
abstract final class Insets {
  /// 2 — optical adjustments.
  static const double xxs = 2;

  /// 4 — hairline gaps between tightly related elements.
  static const double xs = 4;

  /// 8 — gap inside a group.
  static const double sm = 8;

  /// 12 — gap between rows and small cards.
  static const double md = 12;

  /// 16 — the standard card padding and screen margin.
  static const double lg = 16;

  /// 20 — comfortable inner card padding.
  static const double xl = 20;

  /// 28 — gap between sections.
  static const double xxl = 28;

  /// 40 — hero spacing.
  static const double huge = 40;
}

/// The corner-radius scale.
abstract final class Radii {
  /// 6 — tiny markers.
  static const double xs = 6;

  /// 8 — small controls (tooltips, tiny chips).
  static const double sm = 8;

  /// 10 — inline controls.
  static const double md = 10;

  /// 14 — buttons, inputs, segmented controls.
  static const double lg = 14;

  /// 18 — cards and panels.
  static const double xl = 18;

  /// 24 — dialogs and hero surfaces.
  static const double xxl = 24;

  /// Fully rounded (pills).
  static const double pill = 999;

  /// The card border radius.
  static const BorderRadius card = BorderRadius.all(Radius.circular(xl));

  /// The control border radius.
  static const BorderRadius control = BorderRadius.all(Radius.circular(lg));

  /// The pill border radius.
  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(pill),
  );
}

/// Semantic colors for the OpenFit surface stack.
@immutable
class FitTokens extends ThemeExtension<FitTokens> {
  /// Creates the token set.
  const FitTokens({
    required this.bg,
    required this.surface,
    required this.raised,
    required this.high,
    required this.line,
    required this.lineStrong,
    required this.text,
    required this.muted,
    required this.dim,
    required this.accent,
    required this.onAccent,
    required this.ember,
    required this.sage,
    required this.danger,
  });

  /// The page background.
  final Color bg;

  /// The default panel surface.
  final Color surface;

  /// A raised card.
  final Color raised;

  /// A hovered or selected surface.
  final Color high;

  /// Hairline borders.
  final Color line;

  /// Stronger borders and focus rings.
  final Color lineStrong;

  /// Primary text.
  final Color text;

  /// Secondary text.
  final Color muted;

  /// Tertiary text and disabled states.
  final Color dim;

  /// The signal accent.
  final Color accent;

  /// Text on the accent.
  final Color onAccent;

  /// Nutrition and warning accent.
  final Color ember;

  /// Calm secondary accent.
  final Color sage;

  /// Errors and destructive actions.
  final Color danger;

  /// The default warm-ink theme.
  static const FitTokens dark = FitTokens(
    bg: Color(0xFF0B0E0A),
    surface: Color(0xFF10140F),
    raised: Color(0xFF151A13),
    high: Color(0xFF1B2118),
    line: Color(0xFF252C22),
    lineStrong: Color(0xFF37412F),
    text: Color(0xFFF3F0E6),
    muted: Color(0xFFA3AA9A),
    dim: Color(0xFF7C8577),
    accent: Color(0xFFC9F26B),
    onAccent: Color(0xFF101505),
    ember: Color(0xFFF1A45E),
    sage: Color(0xFF9BC4A5),
    danger: Color(0xFFFF8A79),
  );

  @override
  FitTokens copyWith({
    Color? bg,
    Color? surface,
    Color? raised,
    Color? high,
    Color? line,
    Color? lineStrong,
    Color? text,
    Color? muted,
    Color? dim,
    Color? accent,
    Color? onAccent,
    Color? ember,
    Color? sage,
    Color? danger,
  }) {
    return FitTokens(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      raised: raised ?? this.raised,
      high: high ?? this.high,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      dim: dim ?? this.dim,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      ember: ember ?? this.ember,
      sage: sage ?? this.sage,
      danger: danger ?? this.danger,
    );
  }

  @override
  FitTokens lerp(FitTokens? other, double t) {
    if (other == null) return this;
    return FitTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      high: Color.lerp(high, other.high, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      dim: Color.lerp(dim, other.dim, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      ember: Color.lerp(ember, other.ember, t)!,
      sage: Color.lerp(sage, other.sage, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

/// Short access to the OpenFit tokens.
extension FitThemeContext on BuildContext {
  /// The semantic palette for the current theme.
  FitTokens get fit => Theme.of(this).extension<FitTokens>()!;
}

/// The OpenFit wordmark tile.
class FitLogo extends StatelessWidget {
  /// Creates the logo.
  const FitLogo({super.key, this.size = 34});

  /// Edge length of the tile.
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.fit;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tokens.accent,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        Icons.bolt_rounded,
        size: size * 0.62,
        color: tokens.onAccent,
      ),
    );
  }
}

/// A bordered surface card; pass [onTap] for an interactive card.
class AppCard extends StatelessWidget {
  /// Creates a card.
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Insets.lg),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = Radii.xl,
  });

  /// The card's content.
  final Widget child;

  /// Padding inside the card.
  final EdgeInsetsGeometry padding;

  /// When set, the card gets a hover/ripple state and this tap handler.
  final VoidCallback? onTap;

  /// Optional surface color override.
  final Color? color;

  /// Optional border color override.
  final Color? borderColor;

  /// Corner radius.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final tokens = context.fit;
    final shape = BorderRadius.circular(radius);
    final decoration = BoxDecoration(
      color: color ?? tokens.raised,
      borderRadius: shape,
      border: Border.all(color: borderColor ?? tokens.line),
    );
    if (onTap == null) {
      return DecoratedBox(
        decoration: decoration,
        child: Padding(padding: padding, child: child),
      );
    }
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape,
          hoverColor: tokens.accent.withValues(alpha: 0.045),
          splashColor: tokens.accent.withValues(alpha: 0.06),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The small uppercase label above a section, with a signal tick.
class SectionLabel extends StatelessWidget {
  /// Creates a section label.
  const SectionLabel(this.text, {super.key, this.trailing});

  /// The label text (rendered uppercase).
  final String text;

  /// Optional trailing widget, aligned to the end of the row.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.fit;
    return Row(
      children: [
        Container(
          width: 12,
          height: 2,
          color: tokens.accent,
          margin: const EdgeInsets.only(right: Insets.sm),
        ),
        Text(
          text.toUpperCase(),
          style: theme.textTheme.labelSmall!.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
            color: tokens.dim,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

/// A small rounded label used for macros, badges and counts.
class StatChip extends StatelessWidget {
  /// Creates a stat chip.
  const StatChip({
    super.key,
    required this.label,
    this.icon,
    this.tone,
    this.foreground,
    this.dot,
  });

  /// The chip text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional background color (defaults to transparent).
  final Color? tone;

  /// Optional text/icon color (defaults to muted).
  final Color? foreground;

  /// Optional dot color rendered before the label.
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    final tokens = context.fit;
    final background = tone ?? Colors.transparent;
    final content = foreground ?? tokens.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: Radii.pillRadius,
        border: tone == null ? Border.all(color: tokens.line) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: content),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: kFitMonoStyle.copyWith(
              fontSize: 10,
              height: 1.1,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              color: content,
            ),
          ),
        ],
      ),
    );
  }
}

/// Removable filename chips for the attachments picked in a card or composer.
class AttachmentChips extends StatelessWidget {
  /// Creates the chip row.
  const AttachmentChips({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  /// The picked attachments to show.
  final List<PickedAttachment> attachments;

  /// Called when the athlete taps a chip's delete button.
  final void Function(PickedAttachment attachment) onRemove;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: Insets.sm,
      runSpacing: Insets.sm,
      children: [
        for (final attachment in attachments)
          InputChip(
            avatar: const Icon(Icons.attach_file, size: 14),
            label: Text(attachment.label, overflow: TextOverflow.ellipsis),
            onDeleted: () => onRemove(attachment),
            deleteButtonTooltipMessage: 'Remove ${attachment.label}',
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
