import 'dart:convert';

import 'package:flutter/material.dart';

import '../models.dart';
import '../markdown_lite.dart';
import '../theme.dart';

/// Transcript rendering: user bubbles, assistant messages with parts, notices.
class TranscriptView extends StatelessWidget {
  const TranscriptView({
    super.key,
    required this.messages,
    required this.loading,
    required this.hasSession,
    required this.scrollController,
    this.hasOlder = false,
    this.loadingOlder = false,
    this.onLoadEarlier,
  });

  final List<ChatMessage> messages;
  final bool loading;
  final bool hasSession;
  final ScrollController scrollController;

  /// Whether the server reported an earlier page of messages.
  final bool hasOlder;
  final bool loadingOlder;
  final VoidCallback? onLoadEarlier;

  @override
  Widget build(BuildContext context) {
    final visible = messages.where((message) => !message.isEmpty).toList();
    if (visible.isEmpty) {
      return _EmptyTranscript(loading: loading, hasSession: hasSession);
    }
    final headerCount = hasOlder ? 1 : 0;
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
      itemCount: visible.length + headerCount,
      itemBuilder: (context, index) {
        if (headerCount == 1 && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: loadingOlder
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : OutlinedButton.icon(
                      onPressed: onLoadEarlier,
                      icon: const Icon(Icons.history_rounded, size: 16),
                      label: const Text('Load earlier messages'),
                    ),
            ),
          );
        }
        final message = visible[index - headerCount];
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: switch (message.role) {
            ChatRole.user => UserBubble(message: message),
            ChatRole.assistant => AssistantMessage(message: message),
            ChatRole.notice => NoticePill(text: message.notice ?? message.text),
          },
        );
      },
    );
  }
}

class _EmptyTranscript extends StatelessWidget {
  const _EmptyTranscript({required this.loading, required this.hasSession});

  final bool loading;
  final bool hasSession;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.terminal_rounded,
            size: 46,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 14),
          Text(
            hasSession ? 'Start the conversation' : 'Pick or create a session',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            hasSession
                ? 'Type a message below and press Enter. Use @ to reference files.'
                : 'Open the Sessions panel on the left.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(6),
          ),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: MarkdownLite(
          text: message.text,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class AssistantMessage extends StatelessWidget {
  const AssistantMessage({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleParts = message.parts
        .where(
          (part) => switch (part) {
            ChatTextPart(:final text) => text.isNotEmpty,
            ChatReasoningPart(:final text) => text.isNotEmpty,
            ChatToolPart() => true,
          },
        )
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssistantHeader(message: message),
        const SizedBox(height: 8),
        for (final part in visibleParts) ...[
          switch (part) {
            ChatTextPart() => MarkdownLite(
              text: part.text,
              streaming: message.streaming && !part.done,
              style: theme.textTheme.bodyMedium,
            ),
            ChatReasoningPart() => ReasoningBlock(
              part: part,
              streaming: message.streaming && !part.done,
            ),
            ChatToolPart() => ToolCard(part: part),
          },
          const SizedBox(height: 8),
        ],
        if (message.errorMessage != null)
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AssistantHeader extends StatelessWidget {
  const _AssistantHeader({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agent = message.agent ?? 'assistant';
    final model = message.model;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            agent,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (model != null) ...[
          const SizedBox(width: 8),
          Text(
            '${model.providerID}/${model.id}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(width: 8),
        Text(
          clock(message.time),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        if (message.streaming) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 11,
            height: 11,
            child: CircularProgressIndicator(
              strokeWidth: 1.6,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
        if (message.cost != null && message.tokens != null) ...[
          const SizedBox(width: 8),
          Text(
            '${compactTokens(message.tokens!.input)} in / '
            '${compactTokens(message.tokens!.output)} out \u00b7 '
            '\$${message.cost!.toStringAsFixed(4)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ],
    );
  }
}

class ReasoningBlock extends StatefulWidget {
  const ReasoningBlock({
    super.key,
    required this.part,
    required this.streaming,
  });

  final ChatReasoningPart part;
  final bool streaming;

  @override
  State<ReasoningBlock> createState() => _ReasoningBlockState();
}

class _ReasoningBlockState extends State<ReasoningBlock> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 260),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.streaming ? 'Thinking\u2026' : 'Thought process',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: MarkdownLite(
                text: widget.part.text,
                streaming: widget.streaming,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ToolCard extends StatefulWidget {
  const ToolCard({super.key, required this.part});

  final ChatToolPart part;

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final part = widget.part;
    final status = switch (part.status) {
      ChatToolStatus.streaming => ('Preparing', theme.colorScheme.outline),
      ChatToolStatus.running => ('Running', theme.colorScheme.tertiary),
      ChatToolStatus.completed => ('Done', theme.colorScheme.primary),
      ChatToolStatus.failed => ('Failed', theme.colorScheme.error),
    };
    final hasDetails =
        part.input.isNotEmpty ||
        part.inputJson != null ||
        (part.output != null && part.output!.isNotEmpty) ||
        part.error != null;
    return Container(
      constraints: const BoxConstraints(maxWidth: 780, minWidth: 320),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: hasDetails
                ? () => setState(() => _expanded = !_expanded)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: [
                  Icon(
                    toolIcon(part.name),
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 9),
                  Text(part.name, style: theme.textTheme.labelLarge),
                  const SizedBox(width: 10),
                  if (part.status == ChatToolStatus.running ||
                      part.status == ChatToolStatus.streaming)
                    SizedBox(
                      width: 11,
                      height: 11,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.6,
                        color: status.$2,
                      ),
                    )
                  else
                    Icon(
                      part.status == ChatToolStatus.completed
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 14,
                      color: status.$2,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    status.$1,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: status.$2,
                    ),
                  ),
                  if (part.output != null &&
                      !_expanded &&
                      part.output!.isNotEmpty)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          part.output!.split('\n').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (hasDetails)
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 17,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_inputPreview(part) case final input?)
                    MonoBlock(title: 'input', text: input),
                  if (part.output != null && part.output!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    MonoBlock(title: 'output', text: part.output!),
                  ],
                  if (part.error != null) ...[
                    const SizedBox(height: 8),
                    MonoBlock(
                      title: 'error',
                      text: part.error!,
                      color: theme.colorScheme.error,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String? _inputPreview(ChatToolPart part) {
    if (part.inputJson case final json? when json.isNotEmpty) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    }
    if (part.input.isNotEmpty) return part.input;
    return null;
  }
}

/// A titled monospace block used for tool input/output and file previews.
class MonoBlock extends StatelessWidget {
  const MonoBlock({
    super.key,
    required this.title,
    required this.text,
    this.color,
    this.maxHeight = 260,
  });

  final String title;
  final String text;
  final Color? color;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.codeBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              text,
              style: TextStyle(
                fontFamily: kMonoFontFamily,
                fontFamilyFallback: kMonoFontFallback,
                fontSize: 12,
                height: 1.45,
                color: color ?? theme.codeForeground,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NoticePill extends StatelessWidget {
  const NoticePill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.7,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

IconData toolIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('bash') ||
      lower.contains('shell') ||
      lower.contains('terminal')) {
    return Icons.terminal_rounded;
  }
  if (lower.contains('read')) return Icons.description_outlined;
  if (lower.contains('write') ||
      lower.contains('edit') ||
      lower.contains('patch')) {
    return Icons.edit_note_rounded;
  }
  if (lower.contains('glob') ||
      lower.contains('grep') ||
      lower.contains('search') ||
      lower.contains('find')) {
    return Icons.search_rounded;
  }
  if (lower.contains('task') || lower.contains('agent')) {
    return Icons.smart_toy_outlined;
  }
  if (lower.contains('web') || lower.contains('fetch')) {
    return Icons.public_rounded;
  }
  if (lower.contains('skill')) return Icons.auto_awesome_outlined;
  return Icons.build_outlined;
}

String clock(DateTime time) {
  final local = time.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String compactTokens(double value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.round().toString();
}

String timeAgo(DateTime time) {
  final delta = DateTime.now().difference(time.toLocal());
  if (delta.inMinutes < 1) return 'just now';
  if (delta.inHours < 1) return '${delta.inMinutes}m ago';
  if (delta.inDays < 1) return '${delta.inHours}h ago';
  if (delta.inDays < 30) return '${delta.inDays}d ago';
  return '${(delta.inDays / 30).floor()}mo ago';
}
