import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

import '../cockpit_controller.dart';
import '../services/persistent_terminal.dart';
import '../terminal_session.dart';
import '../theme.dart';

/// Bottom drawer that renders a live OpenCode PTY session.
class TerminalPanel extends StatefulWidget {
  const TerminalPanel({super.key, required this.controller});

  final CockpitController controller;

  @override
  State<TerminalPanel> createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.selectedPersistentID == null) {
      widget.controller.ensureTerminal();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final persistent = widget.controller.selectedPersistentID != null
        ? widget.controller.persistentTerminalSession
        : null;
    final session = widget.controller.terminal;
    final xterm = persistent?.terminal ?? session?.terminal;
    final capturedSession = session;
    final label = persistent != null
        ? switch (persistent.status) {
            PersistentTerminalStatus.detached => 'detached',
            PersistentTerminalStatus.connecting => 'connecting',
            PersistentTerminalStatus.attached => 'attached',
            PersistentTerminalStatus.failed => 'failed',
          }
        : switch (capturedSession?.status ?? TerminalStatus.idle) {
            TerminalStatus.idle => 'idle',
            TerminalStatus.starting => 'starting',
            TerminalStatus.running => 'running',
            TerminalStatus.exited => 'exited',
            TerminalStatus.failed => 'failed',
          };
    final color = persistent != null
        ? switch (persistent.status) {
            PersistentTerminalStatus.detached => theme.colorScheme.outline,
            PersistentTerminalStatus.connecting => theme.colorScheme.tertiary,
            PersistentTerminalStatus.attached => const Color(0xFF4ADE80),
            PersistentTerminalStatus.failed => theme.colorScheme.error,
          }
        : switch (capturedSession?.status ?? TerminalStatus.idle) {
            TerminalStatus.idle => theme.colorScheme.outline,
            TerminalStatus.starting => theme.colorScheme.tertiary,
            TerminalStatus.running => const Color(0xFF4ADE80),
            TerminalStatus.exited => theme.colorScheme.error,
            TerminalStatus.failed => theme.colorScheme.error,
          };
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C10),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFF121318),
            child: Row(
              children: [
                const Icon(
                  Icons.terminal_rounded,
                  size: 14,
                  color: Color(0xFF9BA1B0),
                ),
                const SizedBox(width: 8),
                Text(
                  persistent != null ? 'Persistent terminal' : 'Terminal',
                  style: const TextStyle(
                    fontFamily: kMonoFontFamily,
                    fontFamilyFallback: kMonoFontFallback,
                    fontSize: 12,
                    color: Color(0xFFD8DBE6),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(color: color, fontSize: 10.5),
                  ),
                ),
                if (persistent != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    '${widget.controller.selectedPersistentID}',
                    style: const TextStyle(
                      fontFamily: kMonoFontFamily,
                      fontFamilyFallback: kMonoFontFallback,
                      fontSize: 10.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ] else if (capturedSession?.ptyID != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    '${capturedSession!.ptyID}',
                    style: const TextStyle(
                      fontFamily: kMonoFontFamily,
                      fontFamilyFallback: kMonoFontFallback,
                      fontSize: 10.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
                const Spacer(),
                if (persistent != null) ...[
                  Text(
                    'cursor ${persistent.cursor}',
                    style: const TextStyle(
                      fontFamily: kMonoFontFamily,
                      fontFamilyFallback: kMonoFontFallback,
                      fontSize: 10.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Pull screen snapshot',
                    onPressed: () =>
                        widget.controller.snapshotPersistentTerminal(),
                    icon: const Icon(
                      Icons.photo_camera_back_outlined,
                      size: 15,
                      color: Color(0xFF9BA1B0),
                    ),
                  ),
                ] else if (capturedSession != null) ...[
                  Text(
                    'cursor ${capturedSession.cursor}',
                    style: const TextStyle(
                      fontFamily: kMonoFontFamily,
                      fontFamilyFallback: kMonoFontFallback,
                      fontSize: 10.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: capturedSession.status == TerminalStatus.exited
                        ? 'Start a new shell'
                        : 'Restart shell',
                    onPressed: () => widget.controller.restartTerminal(),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 15,
                      color: Color(0xFF9BA1B0),
                    ),
                  ),
                ],
                IconButton(
                  tooltip: 'Close terminal',
                  onPressed: widget.controller.toggleTerminal,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: Color(0xFF9BA1B0),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: xterm == null
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TerminalView(
                    xterm,
                    autofocus: true,
                    theme: TerminalThemes.defaultTheme,
                    textStyle: const TerminalStyle(
                      fontFamily: kMonoFontFamily,
                      fontFamilyFallback: kMonoFontFallback,
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
          ),
        ],
      ),
    );
  }
}
