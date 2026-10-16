import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'copy_button.dart';

/// Renders a minimal markdown subset used by OpenCode replies: `#`/`##`/`###`
/// headings, `-`/`*` and `1.` lists, `>` blockquotes, `---` rules, fenced code
/// blocks (with a language badge and a copy button), inline `code`, **bold**,
/// and *italic* spans. Everything else is plain text.
class MarkdownLite extends StatefulWidget {
  const MarkdownLite({
    super.key,
    required this.text,
    this.streaming = false,
    this.style,
  });

  final String text;

  /// Appends a caret to the last paragraph while text is streaming.
  final bool streaming;

  final TextStyle? style;

  @override
  State<MarkdownLite> createState() => _MarkdownLiteState();
}

class _MarkdownLiteState extends State<MarkdownLite> {
  List<MarkdownBlock> _blocks = const [];
  String? _cachedText;
  bool? _cachedStreaming;

  /// Parses only when the (text, streaming) pair changed, so rebuilding a long
  /// transcript while the last message streams reuses completed parses.
  void _parseIfNeeded() {
    if (_cachedText == widget.text &&
        _cachedStreaming == widget.streaming) {
      return;
    }
    _cachedText = widget.text;
    _cachedStreaming = widget.streaming;
    _blocks = parseMarkdownLite(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = widget.style ?? theme.textTheme.bodyMedium!;
    _parseIfNeeded();
    final children = <Widget>[];
    for (var index = 0; index < _blocks.length; index++) {
      final block = _blocks[index];
      final isLast = index == _blocks.length - 1;
      final caret = widget.streaming && isLast;
      if (index > 0) children.add(const SizedBox(height: 10));
      switch (block) {
        case MarkdownParagraph(:final text):
          if (text.trim().isEmpty) {
            if (children.isNotEmpty) children.removeLast();
            continue;
          }
          children.add(
            SelectableText.rich(
              TextSpan(children: [
                ..._inlineSpans(text.trimRight(), base, theme),
                if (caret) _caretSpan(base, theme),
              ]),
              style: base.copyWith(height: 1.45),
            ),
          );
        case MarkdownHeading(:final level, :final text):
          final heading = base.copyWith(
            fontSize: (base.fontSize ?? 14) +
                switch (level) {
                  1 => 5.0,
                  2 => 3.0,
                  3 => 1.5,
                  _ => 0.5,
                },
            fontWeight: FontWeight.w700,
            height: 1.3,
          );
          children.add(
            SelectableText.rich(
              TextSpan(children: [
                ..._inlineSpans(text, heading, theme),
                if (caret) _caretSpan(heading, theme),
              ]),
              style: heading,
            ),
          );
        case MarkdownListBlock(:final ordered, :final items):
          children.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var item = 0; item < items.length; item++)
                  Padding(
                    padding: EdgeInsets.only(top: item == 0 ? 0 : 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            ordered ? '${item + 1}.' : '\u2022',
                            textAlign: TextAlign.right,
                            style: base.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SelectableText.rich(
                            TextSpan(children: [
                              ..._inlineSpans(items[item].text, base, theme),
                              if (caret && item == items.length - 1)
                                _caretSpan(base, theme),
                            ]),
                            style: base.copyWith(height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        case MarkdownQuote(:final text):
          final quote = base.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          );
          children.add(
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 3,
                    color: theme.colorScheme.primary.withValues(alpha: 0.55),
                  ),
                ),
              ),
              child: SelectableText.rich(
                TextSpan(children: [
                  ..._inlineSpans(text, quote, theme),
                  if (caret) _caretSpan(quote, theme),
                ]),
                style: quote,
              ),
            ),
          );
        case MarkdownRule():
          children.add(
            Container(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          );
        case MarkdownCode():
          children.add(_CodeBlock(block: block));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  static TextSpan _caretSpan(TextStyle base, ThemeData theme) => TextSpan(
        text: '\u258C',
        style: base.copyWith(color: theme.colorScheme.primary),
      );

  static List<TextSpan> _inlineSpans(
    String text,
    TextStyle base,
    ThemeData theme,
  ) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'(`[^`\n]*`|\*\*[^*\n]+\*\*|\*[^*\n]+\*)');
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
            style: monoCopy(
              base,
              fontSize: (base.fontSize ?? 14) - 0.5,
            ).copyWith(
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.6),
            ),
          ),
        );
      } else if (token.startsWith('**')) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: base.copyWith(fontWeight: FontWeight.w600),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: base.copyWith(fontStyle: FontStyle.italic),
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

// -----------------------------------------------------------------------------
// Parsing
// -----------------------------------------------------------------------------

/// One parsed block of the markdown-lite subset. Exposed for tests.
sealed class MarkdownBlock {
  const MarkdownBlock();
}

/// A plain paragraph; soft line breaks are preserved.
final class MarkdownParagraph extends MarkdownBlock {
  const MarkdownParagraph(this.text);

  final String text;
}

/// A `#`-style heading; [level] is clamped to 1-6.
final class MarkdownHeading extends MarkdownBlock {
  const MarkdownHeading(this.level, this.text);

  final int level;
  final String text;
}

/// One entry of a [MarkdownListBlock].
final class MarkdownListItem {
  const MarkdownListItem(this.text);

  final String text;
}

/// A `-`/`*`/`1.` list.
final class MarkdownListBlock extends MarkdownBlock {
  const MarkdownListBlock({required this.ordered, required this.items});

  final bool ordered;
  final List<MarkdownListItem> items;
}

/// A `>` blockquote.
final class MarkdownQuote extends MarkdownBlock {
  const MarkdownQuote(this.text);

  final String text;
}

/// A `---` horizontal rule.
final class MarkdownRule extends MarkdownBlock {
  const MarkdownRule();
}

/// A fenced code block with its optional info string.
final class MarkdownCode extends MarkdownBlock {
  const MarkdownCode({required this.code, this.language});

  final String code;
  final String? language;
}

final _headingPattern = RegExp(r'^(#{1,6})\s+(.*)$');
final _rulePattern = RegExp(r'^([-*_])\1{2,}$');
final _bulletPattern = RegExp(r'^([-*])\s+(.*)$');
final _orderedPattern = RegExp(r'^(\d{1,3})[.)]\s+(.*)$');

/// Splits markdown-lite [source] into renderable blocks.
@visibleForTesting
List<MarkdownBlock> parseMarkdownLite(String source) {
  final blocks = <MarkdownBlock>[];
  final paragraph = StringBuffer();

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    blocks.add(MarkdownParagraph(paragraph.toString()));
    paragraph.clear();
  }

  final lines = source.split('\n');
  var index = 0;
  while (index < lines.length) {
    final line = lines[index];
    final trimmed = line.trim();

    // Fenced code blocks.
    if (trimmed.startsWith('```')) {
      flushParagraph();
      final language = trimmed.substring(3).trim();
      final code = StringBuffer();
      index++;
      while (index < lines.length &&
          !lines[index].trimLeft().startsWith('```')) {
        code.writeln(lines[index]);
        index++;
      }
      index++; // Skip the closing fence (or the end of the source).
      blocks.add(
        MarkdownCode(
          code: code.toString(),
          language: language.isEmpty ? null : language,
        ),
      );
      continue;
    }

    if (trimmed.isEmpty) {
      flushParagraph();
      index++;
      continue;
    }

    if (_headingPattern.firstMatch(trimmed) case final match?) {
      flushParagraph();
      blocks.add(MarkdownHeading(match.group(1)!.length, match.group(2)!));
      index++;
      continue;
    }

    if (_rulePattern.hasMatch(trimmed)) {
      flushParagraph();
      blocks.add(const MarkdownRule());
      index++;
      continue;
    }

    if (trimmed.startsWith('>')) {
      flushParagraph();
      final quote = StringBuffer();
      while (index < lines.length && lines[index].trim().startsWith('>')) {
        final body = lines[index].trim().substring(1).trimLeft();
        if (quote.isNotEmpty) quote.write('\n');
        quote.write(body);
        index++;
      }
      blocks.add(MarkdownQuote(quote.toString()));
      continue;
    }

    final bullet = _bulletPattern.firstMatch(trimmed);
    final ordered = _orderedPattern.firstMatch(trimmed);
    if (bullet != null || ordered != null) {
      flushParagraph();
      final isOrdered = ordered != null;
      final items = <MarkdownListItem>[];
      while (index < lines.length) {
        final candidate = lines[index].trim();
        final match = isOrdered
            ? _orderedPattern.firstMatch(candidate)
            : _bulletPattern.firstMatch(candidate);
        if (match == null) break;
        items.add(MarkdownListItem(match.group(2)!));
        index++;
      }
      blocks.add(MarkdownListBlock(ordered: isOrdered, items: items));
      continue;
    }

    paragraph.writeln(line);
    index++;
  }
  flushParagraph();
  return blocks;
}

// -----------------------------------------------------------------------------
// Code block
// -----------------------------------------------------------------------------

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.block});

  final MarkdownCode block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = block.language;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 340),
      decoration: BoxDecoration(
        color: const Color(0xFF15161C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 6, 0),
            child: Row(
              children: [
                if (language != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23252E),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      language,
                      style: monoStyle(
                        fontSize: 10.5,
                        color: const Color(0xFF9BA3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                CopyButton(text: block.code.trimRight()),
              ],
            ),
          ),
          Flexible(
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    block.code.trimRight(),
                    style: monoStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: const Color(0xFFD8DBE6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
