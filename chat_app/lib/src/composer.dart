import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import 'attachment_picker.dart';

/// Message composer with Enter-to-send, Shift+Enter for newlines, and file
/// attachments.
class Composer extends StatefulWidget {
  const Composer({
    super.key,
    required this.enabled,
    required this.busy,
    required this.onSubmit,
    required this.onInterrupt,
    this.hint = 'Message OpenCode\u2026',
  });

  final bool enabled;
  final bool busy;

  /// Called with the trimmed text and any attached files.
  final void Function(String text, List<PromptInputFileAttachment> files)
      onSubmit;
  final VoidCallback onInterrupt;
  final String hint;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  final TextEditingController _text = TextEditingController();
  final FocusNode _focus = FocusNode(debugLabel: 'composer');
  var _hasText = false;
  var _attaching = false;
  PickedAttachment? _attachment;

  @override
  void initState() {
    super.initState();
    _text.addListener(() {
      final hasText = _text.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _text.text.trim();
    final attachment = _attachment;
    if ((value.isEmpty && attachment == null) || !widget.enabled) return;
    _text.clear();
    final files = attachment == null
        ? const <PromptInputFileAttachment>[]
        : <PromptInputFileAttachment>[
            PromptInputFileAttachment(
              uri: attachment.path,
              name: attachment.name,
            ),
          ];
    setState(() => _attachment = null);
    widget.onSubmit(value, files);
    _focus.requestFocus();
  }

  Future<void> _pickAttachment() async {
    if (_attaching) return;
    setState(() => _attaching = true);
    try {
      final picked = await pickAttachment();
      if (!mounted) return;
      if (picked != null) setState(() => _attachment = picked);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attachment failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _attaching = false);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (!isEnter) return KeyEventResult.ignored;
    if (HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored; // Shift+Enter inserts a newline.
    }
    _submit();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSend = widget.enabled && (_hasText || _attachment != null);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_attachment case final attachment?)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: InputChip(
                avatar: const Icon(Icons.attach_file_rounded, size: 14),
                label: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(
                    attachment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                deleteIcon: const Icon(Icons.close_rounded, size: 14),
                onDeleted: () => setState(() => _attachment = null),
                visualDensity: VisualDensity.compact,
                tooltip: attachment.path,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Focus(
                  onKeyEvent: _onKey,
                  child: TextField(
                    controller: _text,
                    focusNode: _focus,
                    enabled: widget.enabled,
                    minLines: 1,
                    maxLines: 8,
                    autofocus: true,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Attach a file',
                onPressed:
                    widget.enabled && !_attaching ? _pickAttachment : null,
                icon: _attaching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.attach_file_rounded, size: 20),
              ),
              if (widget.busy) ...[
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  tooltip: 'Interrupt execution',
                  onPressed: widget.onInterrupt,
                  icon: const Icon(Icons.stop_rounded, size: 20),
                ),
              ],
              const SizedBox(width: 6),
              IconButton.filled(
                tooltip: widget.busy ? 'Queue message' : 'Send',
                onPressed: canSend ? _submit : null,
                icon: const Icon(Icons.arrow_upward_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Enter to send \u00b7 Shift+Enter for a newline',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
