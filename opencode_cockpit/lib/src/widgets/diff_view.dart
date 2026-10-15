import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import '../theme.dart';

/// Renders a unified diff patch with colored additions and deletions.
class DiffView extends StatelessWidget {
  const DiffView({super.key, required this.diff, this.showHeader = true});

  final FileDiffInfo diff;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = diff.patch.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    diff.file,
                    style: const TextStyle(
                      fontFamily: 'AppMono',
                      fontSize: 12.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '+${diff.additions}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF4ADE80),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '-${diff.deletions}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Container(
            color: theme.codeBackground,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final line in lines) _DiffLine(line: line)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiffLine extends StatelessWidget {
  const _DiffLine({required this.line});

  final String line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? background;
    Color foreground = theme.codeForeground;
    if (line.startsWith('@@')) {
      background = theme.colorScheme.primary.withValues(alpha: 0.12);
      foreground = theme.colorScheme.primary;
    } else if (line.startsWith('+++') || line.startsWith('---')) {
      foreground = theme.colorScheme.outline;
    } else if (line.startsWith('diff ') ||
        line.startsWith('index ') ||
        line.startsWith('new file') ||
        line.startsWith('deleted file') ||
        line.startsWith('similarity ')) {
      foreground = theme.colorScheme.outline;
    } else if (line.startsWith('+')) {
      background = const Color(0xFF4ADE80).withValues(alpha: 0.12);
      foreground = const Color(0xFF86EFAC);
    } else if (line.startsWith('-')) {
      background = theme.colorScheme.error.withValues(alpha: 0.12);
      foreground = const Color(0xFFFCA5A5);
    }
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
      child: Text(
        line,
        style: TextStyle(
          fontFamily: 'AppMono',
          fontSize: 11.8,
          height: 1.42,
          color: foreground,
        ),
      ),
    );
  }
}
