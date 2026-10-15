import 'package:flutter/material.dart';

/// Renders the coach's plain-text/Markdown-lite output.
///
/// Recognizes section headers (ALL CAPS lines and `#` headings), bullet and
/// numbered lines, `**bold**` and `` `code` `` spans. Built for dirty streams:
/// the last line is rendered as-is while generation is in progress.
class PlanBody extends StatelessWidget {
  const PlanBody({super.key, required this.text, this.streaming = false});

  final String text;

  /// Shows a caret at the end of the last line while streaming.
  final bool streaming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodyMedium!.copyWith(height: 1.5);
    final lines = text.split('\n');
    final children = <Widget>[];

    for (var index = 0; index < lines.length; index++) {
      final raw = lines[index];
      final line = raw.trimRight();
      final isLast = index == lines.length - 1;
      if (line.trim().isEmpty) {
        if (!isLast) children.add(const SizedBox(height: 10));
        continue;
      }

      final caret = streaming && isLast
          ? TextSpan(
              text: '\u258C',
              style: base.copyWith(color: theme.colorScheme.primary),
            )
          : null;

      final heading = _headingLevel(line);
      if (heading != null) {
        children.add(
          Padding(
            padding: EdgeInsets.only(top: children.isEmpty ? 0 : 18, bottom: 4),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: heading.text,
                    style: base.copyWith(
                      fontSize: (base.fontSize ?? 14) + (heading.isTitle ? 3 : 1),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  ?caret,
                ],
              ),
            ),
          ),
        );
        continue;
      }

      final bullet = _Bullet.parse(line);
      if (bullet != null) {
        children.add(
          Padding(
            padding: EdgeInsets.only(left: bullet.indent * 14, top: 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: 8),
                  child: Container(
                    width: 4.5,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: SelectableText.rich(
                    TextSpan(
                      children: [
                        ..._inlineSpans(bullet.text, base, theme),
                        ?caret,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: SelectableText.rich(
            TextSpan(
              children: [
                ..._inlineSpans(line, base, theme),
                ?caret,
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  /// Returns the heading text, or null when the line is not a heading.
  static _Heading? _headingLevel(String line) {
    final trimmed = line.trim();
    if (trimmed.startsWith('#')) {
      final text = trimmed.replaceFirst(RegExp(r'^#+\s*'), '').trim();
      if (text.isEmpty) return null;
      return _Heading(text, isTitle: trimmed.startsWith('## '));
    }
    // ALL CAPS section headers produced by the prompt contract.
    if (trimmed.length < 3 || trimmed.length > 64) return null;
    if (!RegExp(r"^[A-Z0-9][A-Z0-9 \-—–&/()'.]+$").hasMatch(trimmed)) {
      return null;
    }
    if (!RegExp(r'[A-Z]{3}').hasMatch(trimmed)) return null;
    return _Heading(trimmed, isTitle: false);
  }

  static List<TextSpan> _inlineSpans(
    String text,
    TextStyle base,
    ThemeData theme,
  ) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'(`[^`\n]*`|\*\*[^*\n]+\*\*)');
    var cursor = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final token = match.group(0)!;
      if (token.startsWith('`')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: base.copyWith(
              fontFamily: 'Menlo',
              fontSize: (base.fontSize ?? 14) - 0.5,
              color: theme.colorScheme.tertiary,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: base.copyWith(fontWeight: FontWeight.w600),
          ),
        );
      }
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return spans;
  }
}

final class _Heading {
  const _Heading(this.text, {required this.isTitle});

  final String text;
  final bool isTitle;
}

final class _Bullet {
  const _Bullet({required this.indent, required this.text});

  final int indent;
  final String text;

  static final _pattern = RegExp(r'^(\s*)(?:[-*•]|\d+[.)])\s+(.*)$');

  static _Bullet? parse(String line) {
    final match = _pattern.firstMatch(line);
    if (match == null) return null;
    final indent = (match.group(1)!.length / 2).floor().clamp(0, 3);
    return _Bullet(indent: indent, text: match.group(2)!.trimRight());
  }
}
