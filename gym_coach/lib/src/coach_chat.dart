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
    final tokens = context.fit;
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
          Container(
            padding: const EdgeInsets.all(Insets.xs),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: Radii.card,
              border: Border.all(color: tokens.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  key: const ValueKey('coach_attach'),
                  tooltip: 'Attach file',
                  onPressed: widget.sending ? null : _pick,
                  icon: const Icon(Icons.attach_file, size: 18),
                ),
                Expanded(
                  child: TextField(
                    key: const ValueKey('coach_input'),
                    controller: _input,
                    enabled: !widget.sending,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Ask your coach…',
                      filled: false,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Insets.xs,
                        vertical: 11,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: Insets.xs),
                if (widget.sending)
                  IconButton.filledTonal(
                    key: const ValueKey('coach_stop'),
                    tooltip: 'Stop',
                    onPressed: widget.onStop,
                    icon: const Icon(Icons.stop_rounded, size: 18),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(40, 40),
                    ),
                  )
                else
                  IconButton.filled(
                    key: const ValueKey('coach_send'),
                    tooltip: 'Send',
                    onPressed: _send,
                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(40, 40),
                      backgroundColor: tokens.accent,
                      foregroundColor: tokens.onAccent,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    final tokens = context.fit;
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Ask Coach'),
              const SizedBox(height: Insets.md),
              Text(
                'A second opinion,\nany time.',
                style: theme.textTheme.headlineMedium!.copyWith(
                  fontSize: 28,
                  height: 1.15,
                  color: tokens.text,
                ),
              ),
              const SizedBox(height: Insets.sm),
              Text(
                'Substitutions, soreness, travel weeks or food — the coach keeps '
                'the whole conversation in context.',
                style: theme.textTheme.bodySmall!.copyWith(
                  color: tokens.muted,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: Insets.xl),
              for (final prompt in const [
                'Swap squats for something knee-friendly',
                'Build a 20-minute hotel-room session',
                'How should I eat on rest days?',
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: Insets.sm),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 13,
                        color: tokens.dim,
                      ),
                      const SizedBox(width: Insets.sm),
                      Expanded(
                        child: Text(
                          prompt,
                          style: theme.textTheme.bodySmall!.copyWith(
                            fontSize: 11.5,
                            color: tokens.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
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
      final tokens = context.fit;
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: Insets.sm, left: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.md,
            vertical: Insets.sm,
          ),
          decoration: BoxDecoration(
            color: tokens.accent.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Radii.lg),
              topRight: Radius.circular(Radii.lg),
              bottomLeft: Radius.circular(Radii.lg),
              bottomRight: Radius.circular(Insets.xs),
            ),
            border: Border.all(color: tokens.accent.withValues(alpha: 0.25)),
          ),
          child: Text(
            message.text,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: tokens.text,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    final tokens = context.fit;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: Insets.sm, right: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 11,
                    color: tokens.accent,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'COACH',
                  style: theme.textTheme.labelSmall!.copyWith(
                    fontSize: 8.5,
                    letterSpacing: 1.5,
                    color: tokens.dim,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
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
                          color: tokens.raised,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(Insets.xs),
                            topRight: Radius.circular(Radii.lg),
                            bottomLeft: Radius.circular(Radii.lg),
                            bottomRight: Radius.circular(Radii.lg),
                          ),
                          border: Border.all(color: tokens.line),
                        ),
                        child: text.isEmpty && streaming
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.6,
                                      color: tokens.accent,
                                    ),
                                  ),
                                  const SizedBox(width: Insets.sm),
                                  Text(
                                    'Thinking…',
                                    style: theme.textTheme.bodySmall!.copyWith(
                                      color: tokens.muted,
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
                                          .copyWith(height: 1.5),
                                    ),
                                    if (streaming)
                                      TextSpan(
                                        text: '\u258C',
                                        style: TextStyle(color: tokens.accent),
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
                    fontSize: 9,
                    letterSpacing: 0.5,
                    color: tokens.dim,
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
    final tokens = context.fit;
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
                    horizontal: Insets.xs,
                    vertical: Insets.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 13,
                        color: tokens.dim,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'THOUGHT',
                        style: theme.textTheme.labelSmall!.copyWith(
                          fontSize: 8.5,
                          letterSpacing: 1.3,
                          color: tokens.dim,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        _open
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 15,
                        color: tokens.dim,
                      ),
                    ],
                  ),
                ),
              ),
              if (_open)
                Container(
                  margin: const EdgeInsets.only(top: Insets.xs, left: 2),
                  padding: const EdgeInsets.only(left: Insets.md),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: tokens.accent.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    reasoning,
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: tokens.muted,
                      height: 1.5,
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
