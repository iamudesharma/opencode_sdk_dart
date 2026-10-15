import 'package:flutter/material.dart';

/// Renders a minimal markdown subset used by OpenCode replies: fenced code
/// blocks, inline `code`, and **bold** spans. Everything else is plain text.
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
      if (block.code) {
        children.add(_CodeBlock(code: block.text));
      } else {
        final trimmed = block.text.trimRight();
        if (trimmed.isEmpty) {
          children.removeLast();
          continue;
        }
        children.add(
          SelectableText.rich(
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
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  static List<({bool code, String text})> _parseBlocks(String source) {
    final blocks = <({bool code, String text})>[];
    final buffer = StringBuffer();
    var inCode = false;
    final lines = source.split('\n');
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final fence = line.trimLeft().startsWith('```');
      if (fence && !inCode) {
        if (buffer.isNotEmpty) {
          blocks.add((code: false, text: buffer.toString()));
          buffer.clear();
        }
        inCode = true;
        continue;
      }
      if (fence && inCode) {
        blocks.add((code: true, text: buffer.toString()));
        buffer.clear();
        inCode = false;
        continue;
      }
      buffer.writeln(line);
    }
    if (buffer.isNotEmpty) {
      blocks.add((code: inCode, text: buffer.toString()));
    }
    return blocks;
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
              fontFamily: 'AppMono',
              backgroundColor:
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              fontSize: (base.fontSize ?? 14) - 0.5,
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

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 340),
      decoration: BoxDecoration(
        color: const Color(0xFF15161C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              code.trimRight(),
              style: const TextStyle(
                fontFamily: 'AppMono',
                fontSize: 12.5,
                height: 1.5,
                color: Color(0xFFD8DBE6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
