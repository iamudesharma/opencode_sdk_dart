import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cockpit_controller.dart';

/// ⌘K command palette overlay.
class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key, required this.controller});

  final CockpitController controller;

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _focus = FocusNode(debugLabel: 'palette');
  var _highlighted = 0;

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<PaletteCommand> get _filtered {
    final query = _query.text.trim().toLowerCase();
    final commands = widget.controller.commands;
    if (query.isEmpty) return commands;
    return [
      for (final command in commands)
        if (command.label.toLowerCase().contains(query)) command,
    ];
  }

  void _run(PaletteCommand command) {
    widget.controller.hidePalette();
    command.run();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.controller.hidePalette();
      return KeyEventResult.handled;
    }
    final filtered = _filtered;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _highlighted = (_highlighted + 1) % filtered.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(
        () => _highlighted =
            (_highlighted - 1 + filtered.length) % filtered.length,
      );
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter && filtered.isNotEmpty) {
      _run(filtered[_highlighted.clamp(0, filtered.length - 1)]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;
    if (_highlighted >= filtered.length) _highlighted = 0;
    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.controller.hidePalette,
        child: Container(
          color: Colors.black.withValues(alpha: 0.45),
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 90),
            child: GestureDetector(
              onTap: () {},
              child: Material(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
                elevation: 12,
                child: Container(
                  width: 520,
                  constraints: const BoxConstraints(maxHeight: 420),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Focus(
                        onKeyEvent: _onKey,
                        child: TextField(
                          controller: _query,
                          focusNode: _focus,
                          autofocus: true,
                          onChanged: (_) => setState(() => _highlighted = 0),
                          decoration: InputDecoration(
                            hintText: 'Type a command\u2026',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 17,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHigh,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final command = filtered[index];
                            final selected = index == _highlighted;
                            return InkWell(
                              onTap: () => _run(command),
                              child: Container(
                                color: selected
                                    ? theme.colorScheme.primaryContainer
                                          .withValues(alpha: 0.35)
                                    : null,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      command.icon,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        command.label,
                                        style: theme.textTheme.bodyMedium,
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
          ),
        ),
      ),
    );
  }
}
