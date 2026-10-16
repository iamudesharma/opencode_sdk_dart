import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import '../cockpit_controller.dart';
import '../theme.dart';

/// Message composer with Enter-to-send, Shift+Enter newline, and `@` file
/// references backed by `filesystem.find`.
///
/// Reference candidates render in a floating card anchored above the input
/// (via the root overlay) instead of pushing the transcript around.
class CockpitComposer extends StatefulWidget {
  const CockpitComposer({
    super.key,
    required this.controller,
    required this.enabled,
    required this.busy,
  });

  final CockpitController controller;
  final bool enabled;
  final bool busy;

  @override
  State<CockpitComposer> createState() => _CockpitComposerState();
}

class _CockpitComposerState extends State<CockpitComposer> {
  var _hasText = false;
  var _mentionStart = -1;
  var _highlighted = 0;

  final LayerLink _mentionLink = LayerLink();
  OverlayEntry? _mentionOverlay;

  @override
  void initState() {
    super.initState();
    widget.controller.composer.addListener(_onTextChanged);
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncMentionOverlay());
  }

  @override
  void dispose() {
    widget.controller.composer.removeListener(_onTextChanged);
    widget.controller.removeListener(_onControllerChanged);
    final overlay = _mentionOverlay;
    _mentionOverlay = null;
    if (overlay?.mounted ?? false) overlay!.remove();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    _syncMentionOverlay();
  }

  void _onTextChanged() {
    final hasText = widget.controller.composer.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
    _detectMention();
    _syncMentionOverlay();
  }

  /// Tracks the `@token` under the caret and asks the controller to search.
  void _detectMention() {
    final text = widget.controller.composer.text;
    final selection = widget.controller.composer.selection;
    if (!selection.isValid) {
      widget.controller.updateReferenceQuery(null);
      _mentionStart = -1;
      return;
    }
    final before = text.substring(0, selection.start);
    final at = before.lastIndexOf('@');
    if (at == -1) {
      widget.controller.updateReferenceQuery(null);
      _mentionStart = -1;
      return;
    }
    final token = before.substring(at + 1);
    if (token.contains(' ') || token.contains('\n')) {
      widget.controller.updateReferenceQuery(null);
      _mentionStart = -1;
      return;
    }
    _mentionStart = at;
    widget.controller.updateReferenceQuery(token);
  }

  /// Inserts or removes the floating candidate card to match the controller.
  void _syncMentionOverlay() {
    if (!mounted) return;
    if (widget.controller.referenceCandidates.isEmpty) {
      final overlay = _mentionOverlay;
      _mentionOverlay = null;
      if (overlay?.mounted ?? false) overlay!.remove();
      return;
    }
    if (_mentionOverlay == null) {
      _mentionOverlay = OverlayEntry(builder: _buildMentionCard);
      Overlay.of(context, rootOverlay: true).insert(_mentionOverlay!);
    } else {
      _mentionOverlay!.markNeedsBuild();
    }
  }

  Widget _buildMentionCard(BuildContext context) {
    final theme = Theme.of(context);
    final candidates = widget.controller.referenceCandidates;
    if (candidates.isEmpty) return const SizedBox.shrink();
    if (_highlighted >= candidates.length) _highlighted = 0;
    return CompositedTransformFollower(
      link: _mentionLink,
      showWhenUnlinked: false,
      targetAnchor: Alignment.topLeft,
      followerAnchor: Alignment.bottomLeft,
      offset: const Offset(0, -8),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Material(
          elevation: 10,
          shadowColor: Colors.black54,
          color: theme.colorScheme.surfaceContainerHigh,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 300,
              maxWidth: 440,
              maxHeight: 236,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.alternate_email_rounded,
                        size: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Reference files',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${candidates.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 6),
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = candidates[index];
                      final selected = index == _highlighted;
                      return InkWell(
                        onTap: () => _insertReference('${candidate.path}'),
                        child: Container(
                          color: selected
                              ? theme.colorScheme.primaryContainer.withValues(
                                  alpha: 0.4,
                                )
                              : null,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                candidate.type == FileSystemEntryType.directory
                                    ? Icons.folder_outlined
                                    : Icons.description_outlined,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${candidate.path}',
                                  style: kMonoTextStyle.copyWith(
                                    fontSize: 12.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _insertReference(String path) {
    final controller = widget.controller;
    final text = controller.composer.text;
    final selection = controller.composer.selection;
    final start = _mentionStart == -1 ? selection.start : _mentionStart;
    final end = selection.start;
    final mention = '@$path ';
    final updated = text.replaceRange(start, end, mention);
    controller.composer.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + mention.length),
    );
    controller.updateReferenceQuery(null);
    _mentionStart = -1;
  }

  void _submit() {
    final controller = widget.controller;
    final value = controller.composer.text.trim();
    if (value.isEmpty || !widget.enabled) return;
    controller.composer.clear();
    controller.send(value);
    controller.composerFocus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.controller.updateReferenceQuery(null);
      return KeyEventResult.handled;
    }
    final candidates = widget.controller.referenceCandidates;
    if (candidates.isNotEmpty &&
        (event.logicalKey == LogicalKeyboardKey.arrowDown ||
            event.logicalKey == LogicalKeyboardKey.arrowUp)) {
      setState(() {
        final delta = event.logicalKey == LogicalKeyboardKey.arrowDown ? 1 : -1;
        _highlighted = (_highlighted + delta).clamp(0, candidates.length - 1);
      });
      _mentionOverlay?.markNeedsBuild();
      return KeyEventResult.handled;
    }
    final isEnter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (!isEnter) return KeyEventResult.ignored;
    if (HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    if (candidates.isNotEmpty) {
      final index = _highlighted.clamp(0, candidates.length - 1);
      _insertReference('${candidates[index].path}');
      return KeyEventResult.handled;
    }
    _submit();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;
    final candidates = controller.referenceCandidates;
    if (_highlighted >= candidates.length) _highlighted = 0;
    return Container(
      decoration: BoxDecoration(
        color: theme.panelBackground,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: CompositedTransformTarget(
                  link: _mentionLink,
                  child: Focus(
                    onKeyEvent: _onKey,
                    child: TextField(
                      controller: controller.composer,
                      focusNode: controller.composerFocus,
                      enabled: widget.enabled,
                      minLines: 1,
                      maxLines: 8,
                      autofocus: true,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText:
                            'Message OpenCode\u2026  '
                            '(@ to reference files)',
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
              ),
              const SizedBox(width: 10),
              if (widget.busy) ...[
                IconButton.filledTonal(
                  tooltip: 'Interrupt execution',
                  onPressed: controller.interrupt,
                  icon: const Icon(Icons.stop_rounded, size: 20),
                ),
                const SizedBox(width: 6),
              ],
              IconButton.filled(
                tooltip: widget.busy ? 'Queue message' : 'Send',
                onPressed: widget.enabled && _hasText ? _submit : null,
                icon: const Icon(Icons.arrow_upward_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Enter to send \u00b7 Shift+Enter for a newline \u00b7 '
              '\u2318K for the command palette',
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
