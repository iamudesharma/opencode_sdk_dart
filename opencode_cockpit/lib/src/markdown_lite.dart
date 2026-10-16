import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';

/// Renders a minimal markdown subset used by OpenCode replies: `#`–`###`
/// headings, `-`/`*` and `1.` lists, `>` blockquotes, `---` rules, fenced
/// code blocks (language badge + copy button), inline `code`, **bold**, and
/// *italic* spans. Everything else is plain text.
class MarkdownLite extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.bodyMedium!;
    final blocks = _parseBlocks(text);
    final children = <Widget>[];
    for (var index = 0; index < blocks.length; index++) {
      final block = blocks[index];
      final isLast = index == blocks.length - 1;
      if (index > 0) children.add(const SizedBox(height: 10));
      children.add(
        _buildBlock(theme, base, block, streaming: streaming, isLast: isLast),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildBlock(
    ThemeData theme,
    TextStyle base,
    _MdBlock block, {
    required bool streaming,
    required bool isLast,
  }) {
    switch (block) {
      case _MdHeading(:final level, :final text):
        final size = switch (level) {
          1 => 20.0,
          2 => 17.0,
          3 => 15.0,
          _ => 13.5,
        };
        return SelectableText.rich(
          TextSpan(children: _inlineSpans(text, base, theme)),
          style: base.copyWith(
            fontSize: size,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        );
      case _MdRule():
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        );
      case _MdCode(:final language, :final code):
        return _FencedCodeBlock(language: language, code: code);
      case _MdQuote(:final lines):
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.35,
            ),
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
                width: 3,
              ),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: SelectableText.rich(
            TextSpan(children: _inlineSpans(lines.join('\n'), base, theme)),
            style: base.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        );
      case _MdList(:final ordered, :final items):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < items.length; index++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: index == items.length - 1 ? 0 : 4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: ordered ? 24 : 20,
                      child: Text(
                        ordered ? '${index + 1}.' : '\u2022',
                        style: base.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SelectableText.rich(
                        TextSpan(
                          children: _inlineSpans(items[index], base, theme),
                        ),
                        style: base.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      case _MdParagraph(:final lines):
        final trimmed = lines.join('\n').trimRight();
        if (trimmed.isEmpty) return const SizedBox.shrink();
        return SelectableText.rich(
          TextSpan(
            children: [
              ..._inlineSpans(trimmed, base, theme),
              if (streaming && isLast)
                TextSpan(
                  text: '\u258C',
                  style: base.copyWith(color: theme.colorScheme.primary),
                ),
            ],
          ),
          style: base.copyWith(height: 1.45),
        );
    }
  }

  static final _fence = RegExp(r'^```(\w*)\s*$');
  static final _heading = RegExp(r'^(#{1,6})\s+(.*)$');
  static final _rule = RegExp(r'^---+$');
  static final _bullet = RegExp(r'^[-*]\s+(.*)$');
  static final _ordered = RegExp(r'^\d+[.)]\s+(.*)$');

  /// Splits [source] into renderable blocks.
  static List<_MdBlock> _parseBlocks(String source) {
    final blocks = <_MdBlock>[];
    final lines = source.split('\n');
    var index = 0;
    while (index < lines.length) {
      final line = lines[index];
      final left = line.trimLeft();

      final fence = _fence.firstMatch(left);
      if (fence != null) {
        final language = fence.group(1) ?? '';
        final code = StringBuffer();
        index++;
        while (index < lines.length &&
            !lines[index].trimLeft().startsWith('```')) {
          code.writeln(lines[index]);
          index++;
        }
        if (index < lines.length) index++; // Closing fence.
        blocks.add(_MdCode(language, code.toString()));
        continue;
      }

      if (_rule.hasMatch(left)) {
        blocks.add(const _MdRule());
        index++;
        continue;
      }

      final heading = _heading.firstMatch(left);
      if (heading != null) {
        blocks.add(_MdHeading(heading.group(1)!.length, heading.group(2)!));
        index++;
        continue;
      }

      if (left.startsWith('>')) {
        final quote = <String>[];
        while (index < lines.length &&
            lines[index].trimLeft().startsWith('>')) {
          quote.add(lines[index].trimLeft().replaceFirst(RegExp(r'^>\s?'), ''));
          index++;
        }
        blocks.add(_MdQuote(quote));
        continue;
      }

      final bullet = _bullet.firstMatch(left);
      final ordered = _ordered.firstMatch(left);
      if (bullet != null || ordered != null) {
        final isOrdered = ordered != null;
        final items = <String>[];
        while (index < lines.length) {
          final match = isOrdered
              ? _ordered.firstMatch(lines[index].trimLeft())
              : _bullet.firstMatch(lines[index].trimLeft());
          if (match == null) break;
          items.add(match.group(1)!);
          index++;
        }
        blocks.add(_MdList(ordered: isOrdered, items: items));
        continue;
      }

      if (left.trim().isEmpty) {
        index++;
        continue;
      }

      final paragraph = <String>[];
      while (index < lines.length) {
        final candidate = lines[index];
        if (candidate.trim().isEmpty || _startsBlock(candidate)) break;
        paragraph.add(candidate);
        index++;
      }
      blocks.add(_MdParagraph(paragraph));
    }
    return blocks;
  }

  static bool _startsBlock(String line) {
    final left = line.trimLeft();
    if (left.startsWith('```')) return true;
    if (_rule.hasMatch(left)) return true;
    if (_heading.hasMatch(left)) return true;
    if (left.startsWith('>')) return true;
    if (_bullet.hasMatch(left)) return true;
    if (_ordered.hasMatch(left)) return true;
    return false;
  }

  static final _inline = RegExp(r'(`[^`\n]*`|\*\*[^*\n]+\*\*|\*[^*\n]+\*)');

  /// Renders inline `code`, **bold**, and *italic* spans.
  static List<TextSpan> _inlineSpans(
    String text,
    TextStyle base,
    ThemeData theme,
  ) {
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in _inline.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final token = match.group(0)!;
      if (token.startsWith('`')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: kMonoTextStyle.copyWith(
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.6),
              fontSize: (base.fontSize ?? 14) - 0.5,
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

sealed class _MdBlock {
  const _MdBlock();
}

final class _MdParagraph extends _MdBlock {
  _MdParagraph(this.lines);

  final List<String> lines;
}

final class _MdHeading extends _MdBlock {
  _MdHeading(this.level, this.text);

  final int level;
  final String text;
}

final class _MdCode extends _MdBlock {
  _MdCode(this.language, this.code);

  final String language;
  final String code;
}

final class _MdList extends _MdBlock {
  _MdList({required this.ordered, required this.items});

  final bool ordered;
  final List<String> items;
}

final class _MdQuote extends _MdBlock {
  _MdQuote(this.lines);

  final List<String> lines;
}

final class _MdRule extends _MdBlock {
  const _MdRule();
}

/// Theme-aware fenced code block with a language badge and copy button.
class _FencedCodeBlock extends StatefulWidget {
  const _FencedCodeBlock({required this.language, required this.code});

  final String language;
  final String code;

  @override
  State<_FencedCodeBlock> createState() => _FencedCodeBlockState();
}

class _FencedCodeBlockState extends State<_FencedCodeBlock> {
  var _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code.trimRight()));
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = theme.colorScheme.outlineVariant.withValues(alpha: 0.5);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.codeBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 4, 6, 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
            ),
            child: Row(
              children: [
                if (widget.language.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.55,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      widget.language.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                TextButton.icon(
                  onPressed: _copy,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 28),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: theme.textTheme.labelSmall,
                  ),
                  icon: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 13,
                    color: _copied
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  label: Text(
                    _copied ? 'Copied' : 'Copy',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _copied
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    widget.code.trimRight(),
                    style: kMonoTextStyle.copyWith(
                      fontSize: 12.5,
                      height: 1.5,
                      color: theme.codeForeground,
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
