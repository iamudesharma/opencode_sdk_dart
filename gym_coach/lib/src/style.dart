/// Shared spacing, radii and small surface widgets for the OpenFit UI.
///
/// Everything visual in the app builds from this scale, so the desktop and
/// phone shells stay consistent without a design-system dependency.
library;

import 'package:flutter/material.dart';

import 'attachments.dart';

/// The spacing scale, in logical pixels.
abstract final class Insets {
  /// 4 — hairline gaps between tightly related elements.
  static const double xs = 4;

  /// 8 — gap inside a group.
  static const double sm = 8;

  /// 12 — gap between rows and small cards.
  static const double md = 12;

  /// 16 — the standard card padding and screen margin.
  static const double lg = 16;

  /// 24 — gap between sections.
  static const double xl = 24;

  /// 32 — hero spacing.
  static const double xxl = 32;
}

/// The corner-radius scale.
abstract final class Radii {
  /// 8 — small controls (tooltips, tiny chips).
  static const double sm = 8;

  /// 12 — buttons, inputs, segmented controls.
  static const double md = 12;

  /// 16 — cards and dialogs.
  static const double lg = 16;

  /// Fully rounded (pills).
  static const double pill = 999;

  /// The card border radius.
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));

  /// The control border radius.
  static const BorderRadius control = BorderRadius.all(Radius.circular(md));

  /// The pill border radius.
  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(pill),
  );
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
  });

  /// The card's content.
  final Widget child;

  /// Padding inside the card.
  final EdgeInsetsGeometry padding;

  /// When set, the card gets a hover/ripple state and this tap handler.
  final VoidCallback? onTap;

  /// Optional surface color override.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.cardTheme.color;
    if (onTap == null) {
      return Card(
        color: effectiveColor,
        child: Padding(padding: padding, child: child),
      );
    }
    return Card(
      color: effectiveColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: theme.colorScheme.primary.withValues(alpha: 0.06),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// The small uppercase label above a section.
class SectionLabel extends StatelessWidget {
  /// Creates a section label.
  const SectionLabel(this.text, {super.key});

  /// The label text (rendered uppercase).
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall!.copyWith(
        letterSpacing: 1.0,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurfaceVariant,
      ),
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
  });

  /// The chip text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional background color (defaults to the secondary container).
  final Color? tone;

  /// Optional text/icon color (defaults to the secondary container's content).
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = tone ?? theme.colorScheme.secondaryContainer;
    final content = foreground ?? theme.colorScheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: Radii.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: content),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall!.copyWith(color: content),
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
