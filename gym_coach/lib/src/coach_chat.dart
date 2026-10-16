/// The "Ask Coach" chat surface.
///
/// The message list is owned by [HomeScreen]; this widget renders it and owns
/// the transient composer state (draft text + pending attachments). Streaming
/// text and reasoning live in [ValueNotifier]s on [CoachChatMessage], so a
/// token delta rebuilds only its bubble — never the whole app.
library;

import 'package:flutter/material.dart';

import 'attachments.dart';
import 'style.dart';

/// One chat bubble.
final class CoachChatMessage {
  /// A message from the athlete.
  CoachChatMessage.user(this.text) : fromUser = true;

  /// A (possibly still streaming) coach reply.
  CoachChatMessage.coach() : fromUser = false, text = '';

  /// Whether the bubble is right-aligned (athlete) or left-aligned (coach).
  final bool fromUser;

  /// The settled text: the athlete's message or the coach's final answer.
  String text;

  /// Whether the turn was stopped by the athlete.
  bool cancelled = false;

  /// The reply text as it streams in.
  final ValueNotifier<String> streamed = ValueNotifier<String>('');

  /// The reasoning text as it streams in.
  final ValueNotifier<String> reasoning = ValueNotifier<String>('');

  /// Whether the reply is still arriving.
  final ValueNotifier<bool> streaming = ValueNotifier<bool>(false);

  /// Releases the bubble's notifiers.
  void dispose() {
    streamed.dispose();
    reasoning.dispose();
    streaming.dispose();
  }
}

/// Renders the message list, the streaming bubbles and the composer.
class CoachChatPanel extends StatefulWidget {
  /// Creates the panel.
  const CoachChatPanel({
    super.key,
    required this.messages,
    required this.sending,
    required this.activity,
    required this.onSend,
    required this.onStop,
    required this.onRebuildPlan,
    this.padding = const EdgeInsets.all(Insets.lg),
  });

  /// The chat history, oldest first.
  final List<CoachChatMessage> messages;

  /// Whether a turn is in flight (Send turns into Stop).
  final bool sending;

  /// Bumped by the owner on every streamed delta so the list can follow.
  final Listenable activity;

  /// Sends [text] with the composer's picked attachments.
  final void Function(String text, List<PickedAttachment> attachments) onSend;

  /// Aborts the in-flight turn.
  final VoidCallback onStop;

  /// Runs a typed plan again with the given note appended to the request.
  final void Function(String note) onRebuildPlan;

  /// Padding around the panel content.
  final EdgeInsetsGeometry padding;

  @override
  State<CoachChatPanel> createState() => _CoachChatPanelState();
}

class _CoachChatPanelState extends State<CoachChatPanel> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  var _attachments = const <PickedAttachment>[];
  var _scrollScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.activity.addListener(_scheduleScroll);
  }

  @override
  void didUpdateWidget(CoachChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity != widget.activity) {
      oldWidget.activity.removeListener(_scheduleScroll);
      widget.activity.addListener(_scheduleScroll);
    }
    _scheduleScroll();
  }

  @override
  void dispose() {
    widget.activity.removeListener(_scheduleScroll);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scheduleScroll() {
    if (_scrollScheduled) return;
    _scrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (!mounted || !_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty || widget.sending) return;
    widget.onSend(text, _attachments);
    setState(() {
      _input.clear();
      _attachments = const [];
    });
    _scheduleScroll();
  }

  Future<void> _pick() async {
    final picked = await pickAttachment();
    if (!mounted) return;
    if (picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Attachments need the LAN host (dart run tool/lan_host.dart).',
          ),
        ),
      );
      return;
    }
    setState(() => _attachments = [..._attachments, picked]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: widget.messages.isEmpty
                ? _buildEmpty(theme)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.only(bottom: Insets.sm),
                    itemCount: widget.messages.length,
                    itemBuilder: (context, index) => _ChatBubble(
                      message: widget.messages[index],
                      onRebuildPlan: widget.onRebuildPlan,
                    ),
                  ),
          ),
          const SizedBox(height: Insets.sm),
          if (_attachments.isNotEmpty) ...[
            AttachmentChips(
              attachments: _attachments,
              onRemove: (attachment) => setState(
                () => _attachments = [
                  for (final kept in _attachments)
                    if (kept != attachment) kept,
                ],
              ),
            ),
            const SizedBox(height: Insets.sm),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                key: const ValueKey('coach_attach'),
                tooltip: 'Attach file',
                onPressed: widget.sending ? null : _pick,
                icon: const Icon(Icons.attach_file, size: 20),
              ),
              Expanded(
                child: TextField(
                  key: const ValueKey('coach_input'),
                  controller: _input,
                  enabled: !widget.sending,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'Ask your coach…',
                  ),
                ),
              ),
              const SizedBox(width: Insets.sm),
              if (widget.sending)
                FilledButton.tonalIcon(
                  key: const ValueKey('coach_stop'),
                  onPressed: widget.onStop,
                  icon: const Icon(Icons.stop_circle_outlined, size: 18),
                  label: const Text('Stop'),
                )
              else
                FilledButton.icon(
                  key: const ValueKey('coach_send'),
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Send'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 34,
            color: theme.colorScheme.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(height: Insets.md),
          Text('Ask your coach', style: theme.textTheme.titleSmall),
          const SizedBox(height: Insets.xs),
          Text(
            'Questions about your plan, substitutions, soreness or food — '
            'the coach keeps the whole conversation in context.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

/// One bubble, with the reasoning block and the rebuild action for replies.
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.onRebuildPlan});

  final CoachChatMessage message;
  final void Function(String note) onRebuildPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (message.fromUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: Insets.sm, left: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.md,
            vertical: Insets.sm,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Radii.lg),
              topRight: Radius.circular(Radii.lg),
              bottomLeft: Radius.circular(Radii.lg),
              bottomRight: Radius.circular(Insets.xs),
            ),
          ),
          child: Text(
            message.text,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: Insets.sm, right: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReasoningBlock(reasoning: message.reasoning),
            ValueListenableBuilder<bool>(
              valueListenable: message.streaming,
              builder: (context, streaming, _) =>
                  ValueListenableBuilder<String>(
                    valueListenable: message.streamed,
                    builder: (context, streamed, _) {
                      final text = streaming && streamed.isNotEmpty
                          ? streamed
                          : message.text;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Insets.md,
                          vertical: Insets.sm,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(Insets.xs),
                            topRight: Radius.circular(Radii.lg),
                            bottomLeft: Radius.circular(Radii.lg),
                            bottomRight: Radius.circular(Radii.lg),
                          ),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        child: text.isEmpty && streaming
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: Insets.sm),
                                  Text(
                                    'Thinking…',
                                    style: theme.textTheme.bodySmall!.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              )
                            : Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: text,
                                      style: theme.textTheme.bodyMedium!
                                          .copyWith(height: 1.45),
                                    ),
                                    if (streaming)
                                      TextSpan(
                                        text: '\u258C',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
            ),
            if (message.cancelled)
              Padding(
                padding: const EdgeInsets.only(top: Insets.xs),
                child: Text(
                  'Stopped by the athlete.',
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ValueListenableBuilder<bool>(
              valueListenable: message.streaming,
              builder: (context, streaming, _) {
                if (streaming || message.text.trim().isEmpty) {
                  return const SizedBox.shrink();
                }
                return Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => onRebuildPlan(message.text),
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('Rebuild plan with this note'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A collapsible "Thought" block for the model's reasoning stream.
class _ReasoningBlock extends StatefulWidget {
  const _ReasoningBlock({required this.reasoning});

  final ValueNotifier<String> reasoning;

  @override
  State<_ReasoningBlock> createState() => _ReasoningBlockState();
}

class _ReasoningBlockState extends State<_ReasoningBlock> {
  var _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<String>(
      valueListenable: widget.reasoning,
      builder: (context, reasoning, _) {
        if (reasoning.trim().isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: Insets.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: Radii.control,
                onTap: () => setState(() => _open = !_open),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.sm,
                    vertical: Insets.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: Insets.xs),
                      Text(
                        'Thought',
                        style: theme.textTheme.labelSmall!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Icon(
                        _open ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              if (_open)
                Container(
                  margin: const EdgeInsets.only(top: Insets.xs),
                  padding: const EdgeInsets.all(Insets.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: Radii.control,
                  ),
                  child: Text(
                    reasoning,
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
