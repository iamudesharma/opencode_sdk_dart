import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import '../cockpit_controller.dart';
import '../theme.dart';
import 'transcript.dart';

/// Explorer column when the Sessions tab is active: searchable session tree.
class SessionExplorer extends StatelessWidget {
  const SessionExplorer({super.key, required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roots = controller.visibleRoots;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 4),
          child: Row(
            children: [
              Text('SESSIONS', style: theme.microLabel.copyWith(fontSize: 8.5)),
              const SizedBox(width: 8),
              Text(
                '${roots.length}',
                style: kMonoTextStyle.copyWith(
                  fontSize: 9,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'New session',
                onPressed: () => controller.newSession(),
                icon: const Icon(Icons.add_rounded, size: 17),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: TextField(
            onChanged: (value) {
              controller.sessionFilter = value;
              controller.selectExplorerTab(ExplorerTab.sessions);
            },
            decoration: InputDecoration(
              hintText: 'Search sessions',
              isDense: true,
              prefixIcon: const Icon(Icons.search_rounded, size: 15),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 32,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: theme.textTheme.bodySmall,
          ),
        ),
        if (controller.loadingSessions && roots.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (roots.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No sessions in this project yet.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: roots.length,
              itemBuilder: (context, index) =>
                  SessionTile(controller: controller, node: roots[index]),
            ),
          ),
      ],
    );
  }
}

class SessionTile extends StatelessWidget {
  const SessionTile({super.key, required this.controller, required this.node});

  final CockpitController controller;
  final SessionNode node;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = node.info;
    final selected = controller.activeSession?.id == session.id;
    final busy = controller.busySessionIDs.contains(session.id);
    final cost = controller.usage[session.id]?.cost ?? session.cost;
    return Padding(
      padding: EdgeInsets.only(bottom: 2, left: node.depth * 14),
      child: Material(
        color: selected ? theme.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: () => controller.openSession(session),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 4, 6),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  child: node.childrenLoaded && node.children.isEmpty
                      ? const SizedBox.shrink()
                      : InkWell(
                          onTap: () => controller.toggleNode(node),
                          child: Icon(
                            node.expanded
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_right_rounded,
                            size: 15,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                if (busy)
                  const SizedBox(
                    width: 11,
                    height: 11,
                    child: CircularProgressIndicator(strokeWidth: 1.6),
                  )
                else
                  Icon(
                    node.depth > 0
                        ? Icons.subdirectory_arrow_right_rounded
                        : Icons.chat_bubble_outline_rounded,
                    size: 12,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                const SizedBox(width: 8),
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
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontSize: 11.5,
                          color: selected
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (!node.childrenLoaded || node.children.isNotEmpty)
                            Tooltip(
                              message: 'Has sub-sessions',
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.account_tree_outlined,
                                  size: 9,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              '${timeAgo(DateTime.fromMillisecondsSinceEpoch(session.time.updated.round()))} \u00b7 '
                              '\$${cost.toStringAsFixed(4)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: kMonoTextStyle.copyWith(
                                fontSize: 9,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SessionMenu(controller: controller, session: session),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SessionMenu extends StatelessWidget {
  const SessionMenu({
    super.key,
    required this.controller,
    required this.session,
  });

  final CockpitController controller;
  final SessionInfo session;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Session actions',
      iconSize: 16,
      padding: EdgeInsets.zero,
      onSelected: (value) async {
        switch (value) {
          case 'rename':
            final title = await _promptRename(context, session);
            if (title != null && title.trim().isNotEmpty) {
              await controller.renameSession(session, title.trim());
            }
          case 'fork':
            await controller.forkSession(session);
          case 'changes':
            await controller.openSession(session);
            controller.showInspector(InspectorTab.changes);
          case 'export':
            controller.onShowExport?.call();
          case 'import':
            controller.onShowImport?.call();
          case 'delete':
            final confirmed = await _confirmDelete(context, session);
            if (confirmed) await controller.deleteSession(session);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'rename', child: Text('Rename')),
        PopupMenuItem(value: 'fork', child: Text('Fork session')),
        PopupMenuItem(value: 'changes', child: Text('Review changes')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'export', child: Text('Export transcript\u2026')),
        PopupMenuItem(value: 'import', child: Text('Import transcript\u2026')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }

  static Future<String?> _promptRename(
    BuildContext context,
    SessionInfo session,
  ) async {
    final textController = TextEditingController(text: session.title ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename session'),
        content: TextField(
          controller: textController,
          autofocus: true,
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
    textController.dispose();
    return result;
  }

  static Future<bool> _confirmDelete(
    BuildContext context,
    SessionInfo session,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete session?'),
        content: Text(
          '"${session.title ?? session.id}" and its sub-sessions will be '
          'deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
