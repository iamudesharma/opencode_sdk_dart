import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import '../theme.dart';

/// Explorer-style list of persistent terminals for the active session.
class PersistentTerminalsPanel extends StatelessWidget {
  const PersistentTerminalsPanel({
    super.key,
    required this.terminals,
    required this.selectedID,
    required this.onSelect,
    required this.onCreate,
    required this.onRefresh,
    required this.onKill,
    this.loading = false,
  });

  /// The session's persistent terminals.
  final List<PersistentPtyInfo> terminals;

  /// The terminal highlighted as selected.
  final PtyID? selectedID;

  /// Called when a terminal row is tapped.
  final ValueChanged<PersistentPtyInfo> onSelect;

  /// Called when the New button is pressed.
  final VoidCallback onCreate;

  /// Called when the Refresh button is pressed.
  final VoidCallback onRefresh;

  /// Called after the user confirms killing a terminal.
  final ValueChanged<PersistentPtyInfo> onKill;

  /// Whether the terminal list is being refreshed.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 6),
          child: Row(
            children: [
              Icon(
                Icons.terminal_rounded,
                size: 15,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Text('Terminals', style: theme.textTheme.labelLarge),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${terminals.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 1.8),
                  ),
                )
              else
                IconButton(
                  tooltip: 'Refresh terminals',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                ),
              IconButton(
                tooltip: 'New terminal',
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded, size: 16),
              ),
            ],
          ),
        ),
        Expanded(
          child: terminals.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'No persistent terminals for this session',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: terminals.length,
                  itemBuilder: (context, index) {
                    final terminal = terminals[index];
                    return _TerminalTile(
                      terminal: terminal,
                      selected: terminal.id == selectedID,
                      onSelect: onSelect,
                      onKill: onKill,
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Text(
            'Persistent terminals survive app restarts',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}

class _TerminalTile extends StatelessWidget {
  const _TerminalTile({
    required this.terminal,
    required this.selected,
    required this.onSelect,
    required this.onKill,
  });

  final PersistentPtyInfo terminal;
  final bool selected;
  final ValueChanged<PersistentPtyInfo> onSelect;
  final ValueChanged<PersistentPtyInfo> onKill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final running = terminal.status == PersistentPtyInfoStatus.running;
    final color = running ? const Color(0xFF4ADE80) : theme.colorScheme.error;
    return InkWell(
      onTap: () => onSelect(terminal),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tooltip(
                    message: terminal.command,
                    child: Text(
                      terminal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    terminal.cwd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: kMonoFontFamily,
                      fontFamilyFallback: kMonoFontFallback,
                      fontSize: 10.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'pid ${terminal.pid}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: kMonoFontFamily,
                fontFamilyFallback: kMonoFontFallback,
                color: theme.colorScheme.outline,
              ),
            ),
            IconButton(
              tooltip: 'Kill terminal',
              onPressed: () => _confirmKill(context),
              icon: const Icon(Icons.close_rounded, size: 14),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmKill(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kill terminal?'),
        content: const Text('The terminal is terminated on the server'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Kill'),
          ),
        ],
      ),
    );
    if (confirmed == true) onKill(terminal);
  }
}
