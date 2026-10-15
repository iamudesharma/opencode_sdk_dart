import 'dart:convert';

import 'package:flutter/material.dart';

import 'chat_controller.dart';
import 'chat_models.dart';
import 'markdown_lite.dart';

/// The scrolling transcript for the active session.
class ChatTranscript extends StatefulWidget {
  const ChatTranscript({super.key, required this.controller});

  final ChatController controller;

  @override
  State<ChatTranscript> createState() => _ChatTranscriptState();
}

class _ChatTranscriptState extends State<ChatTranscript> {
  final ScrollController _scroll = ScrollController();
  var _wasNearBottom = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _scroll.addListener(_trackPosition);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _scroll
      ..removeListener(_trackPosition)
      ..dispose();
    super.dispose();
  }

  void _trackPosition() {
    if (!_scroll.hasClients) return;
    _wasNearBottom = _distanceFromBottom < 140;
  }

  double get _distanceFromBottom {
    if (!_scroll.hasClients) return 0;
    final position = _scroll.position;
    return position.maxScrollExtent - position.pixels;
  }

  void _onControllerChanged() {
    if (!mounted) return;
    if (!_wasNearBottom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  void _jumpToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final messages = controller.messages
        .where((message) => !message.isEmpty)
        .toList(growable: false);
    if (messages.isEmpty) {
      return _EmptyTranscript(
        loading: controller.loadingMessages,
        hasSession: controller.activeSession != null,
      );
    }
    return Stack(
      children: [
        ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: switch (message.role) {
                ChatRole.user => _UserBubble(message: message),
                ChatRole.assistant => _AssistantMessage(message: message),
                ChatRole.notice => _NoticePill(text: message.notice ?? message.text),
              },
            );
          },
        ),
        if (!_wasNearBottom)
          Positioned(
            right: 24,
            bottom: 12,
            child: FloatingActionButton.small(
              heroTag: 'jump-to-bottom',
              onPressed: () {
                _jumpToBottom();
                setState(() => _wasNearBottom = true);
              },
              child: const Icon(Icons.arrow_downward, size: 18),
            ),
          ),
      ],
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
            size: 44,
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
                ? 'Type a message below and press Enter.'
                : 'The transcript appears here.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
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

class _AssistantMessage extends StatelessWidget {
  const _AssistantMessage({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleParts = message.parts
        .where((part) => switch (part) {
              ChatTextPart(:final text) => text.isNotEmpty,
              ChatReasoningPart(:final text) => text.isNotEmpty,
              ChatToolPart() => true,
            })
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
            ChatReasoningPart() => _ReasoningBlock(
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
                Icon(Icons.error_outline,
                    size: 16, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message.errorMessage!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
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
    final chips = <Widget>[
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          agent,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
      if (model != null)
        Text(
          '${model.providerID}/${model.id}',
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      Text(
        _clock(message.time),
        style: theme.textTheme.labelSmall
            ?.copyWith(color: theme.colorScheme.outline),
      ),
      if (message.streaming)
        SizedBox(
          width: 11,
          height: 11,
          child: CircularProgressIndicator(
            strokeWidth: 1.6,
            color: theme.colorScheme.primary,
          ),
        ),
      if (message.cost != null && message.tokens != null)
        Text(
          '${_tokens(message.tokens!.input)} in / '
          '${_tokens(message.tokens!.output)} out \u00b7 \$${message.cost!.toStringAsFixed(4)}',
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.outline),
        ),
    ];
    return Row(
      children: [
        for (var index = 0; index < chips.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Flexible(child: chips[index]),
        ],
      ],
    );
  }
}

class _ReasoningBlock extends StatefulWidget {
  const _ReasoningBlock({required this.part, required this.streaming});

  final ChatReasoningPart part;
  final bool streaming;

  @override
  State<_ReasoningBlock> createState() => _ReasoningBlockState();
}

class _ReasoningBlockState extends State<_ReasoningBlock> {
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
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
    final hasDetails = part.input.isNotEmpty ||
        part.inputJson != null ||
        (part.output != null && part.output!.isNotEmpty) ||
        part.error != null;
    return Container(
      constraints: const BoxConstraints(maxWidth: 760, minWidth: 320),
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
                    _toolIcon(part.name),
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    part.name,
                    style: theme.textTheme.labelLarge,
                  ),
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
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: status.$2),
                  ),
                  if (part.output != null && !_expanded && part.output!.isNotEmpty)
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
                    _MonoBlock(title: 'input', text: input),
                  if (part.output != null && part.output!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _MonoBlock(title: 'output', text: part.output!),
                  ],
                  if (part.error != null) ...[
                    const SizedBox(height: 8),
                    _MonoBlock(
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

class _MonoBlock extends StatelessWidget {
  const _MonoBlock({required this.title, required this.text, this.color});

  final String title;
  final String text;
  final Color? color;

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
          constraints: const BoxConstraints(maxHeight: 260),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF14151A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              text,
              style: TextStyle(
                fontFamily: 'AppMono',
                fontSize: 12,
                height: 1.45,
                color: color ?? const Color(0xFFD8DBE6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoticePill extends StatelessWidget {
  const _NoticePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

IconData _toolIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('bash') ||
      lower.contains('shell') ||
      lower.contains('terminal')) {
    return Icons.terminal_rounded;
  }
  if (lower.contains('read')) return Icons.description_outlined;
  if (lower.contains('write') || lower.contains('edit') || lower.contains('patch')) {
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
  return Icons.build_outlined;
}

String _clock(DateTime time) {
  final local = time.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _tokens(double value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.round().toString();
}
