import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import 'chat_controller.dart';

/// Session list and connection controls.
class SessionSidebar extends StatelessWidget {
  const SessionSidebar({
    super.key,
    required this.controller,
    required this.onNewChat,
    required this.onOpenSession,
    required this.onRefresh,
    required this.onReconnect,
  });

  final ChatController controller;
  final VoidCallback onNewChat;
  final ValueChanged<SessionInfo> onOpenSession;
  final VoidCallback onRefresh;
  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 12, 12),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B7CF6), Color(0xFF4FC3F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.terminal_rounded,
                      size: 17, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OpenCode', style: theme.textTheme.titleSmall),
                      if (controller.serverVersion != null)
                        Text(
                          'v${controller.serverVersion}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh sessions',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                ),
                IconButton(
                  tooltip: 'Reconnect',
                  onPressed: onReconnect,
                  icon: const Icon(Icons.link_rounded, size: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: FilledButton.icon(
              onPressed: onNewChat,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New chat'),
            ),
          ),
          Expanded(
            child: controller.sessions.isEmpty
                ? Center(
                    child: Text(
                      'No sessions yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: controller.sessions.length,
                    itemBuilder: (context, index) {
                      final session = controller.sessions[index];
                      return _SessionTile(
                        session: session,
                        selected: controller.activeSession?.id == session.id,
                        busy: controller.busySessionIDs.contains(session.id),
                        cost: controller.usage[session.id]?.cost ?? session.cost,
                        onTap: () => onOpenSession(session),
                        onDelete: () =>
                            controller.deleteSession(session.id),
                        onRename: () => _rename(context, session),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: controller.isConnected
                        ? const Color(0xFF4ADE80)
                        : theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.baseUrl?.toString() ?? 'not connected',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, SessionInfo session) async {
    final textController = TextEditingController(text: session.title ?? '');
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename session'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Session title'),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(textController.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    if (title == null || title.trim().isEmpty) return;
    await controller.renameActiveSession(title.trim());
    await controller.refreshSessions();
  }
}

class _SessionTile extends StatefulWidget {
  const _SessionTile({
    required this.session,
    required this.selected,
    required this.busy,
    required this.cost,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  final SessionInfo session;
  final bool selected;
  final bool busy;
  final MoneyUSD cost;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  @override
  State<_SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<_SessionTile> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = widget.session;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: widget.selected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
              : _hovered
                  ? theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.6)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Row(
                children: [
                  if (widget.busy)
                    const SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(strokeWidth: 1.8),
                    )
                  else
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 14,
                      color: widget.selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title?.trim().isNotEmpty == true
                              ? session.title!
                              : 'Untitled session',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: widget.selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_timeAgo(DateTime.fromMillisecondsSinceEpoch(session.time.updated.round()))} \u00b7 \$${widget.cost.toStringAsFixed(4)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_hovered)
                    PopupMenuButton<String>(
                      tooltip: 'Session actions',
                      iconSize: 16,
                      padding: EdgeInsets.zero,
                      onSelected: (value) => switch (value) {
                        'rename' => widget.onRename(),
                        'delete' => widget.onDelete(),
                        _ => null,
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'rename', child: Text('Rename')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _timeAgo(DateTime time) {
  final delta = DateTime.now().difference(time.toLocal());
  if (delta.inMinutes < 1) return 'just now';
  if (delta.inHours < 1) return '${delta.inMinutes}m ago';
  if (delta.inDays < 1) return '${delta.inHours}h ago';
  if (delta.inDays < 30) return '${delta.inDays}d ago';
  return '${(delta.inDays / 30).floor()}mo ago';
}
