import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import '../cockpit_controller.dart';

/// Explorer column when the Git tab is active.
class GitPanel extends StatelessWidget {
  const GitPanel({super.key, required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = controller.vcsInfo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 6),
          child: Row(
            children: [
              Icon(
                Icons.account_tree_outlined,
                size: 15,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info == null
                      ? 'Git'
                      : '${info.provider} \u00b7 '
                            '${info.branch.current ?? info.branch.defaultValue ?? '?'}',
                  style: theme.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.loadingGit)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.8),
                )
              else
                IconButton(
                  tooltip: 'Refresh git state',
                  onPressed: () => controller.loadGit(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _Section(
                title: 'Changes',
                trailing: '${controller.gitChanges.length}',
                child: controller.gitChanges.isEmpty
                    ? _Empty('Working tree clean')
                    : Column(
                        children: [
                          for (final change in controller.gitChanges)
                            _ChangeTile(controller: controller, change: change),
                        ],
                      ),
              ),
              _Section(
                title: 'Worktrees',
                trailing: '${controller.worktrees.length}',
                actions: [
                  IconButton(
                    tooltip: 'New worktree',
                    onPressed: () => _promptWorktree(context),
                    icon: const Icon(Icons.add_rounded, size: 15),
                  ),
                  IconButton(
                    tooltip: 'Refresh worktrees',
                    onPressed: () => controller.loadGit(),
                    icon: const Icon(Icons.sync_rounded, size: 15),
                  ),
                ],
                child: controller.worktrees.isEmpty
                    ? _Empty('No worktrees')
                    : Column(
                        children: [
                          for (final worktree in controller.worktrees)
                            _WorktreeTile(
                              controller: controller,
                              worktree: worktree,
                            ),
                        ],
                      ),
              ),
              _Section(
                title: 'Branches',
                trailing: '${controller.branches.length}',
                child: controller.branches.isEmpty
                    ? _Empty('No branches')
                    : Column(
                        children: [
                          for (final branch in controller.branches.take(25))
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    branch == info?.branch.current
                                        ? Icons.check_rounded
                                        : Icons.commit_rounded,
                                    size: 12,
                                    color: branch == info?.branch.current
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      branch,
                                      style: theme.textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _promptWorktree(BuildContext context) async {
    final textController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create worktree'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'branch or task name'),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(textController.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    textController.dispose();
    if (name != null && name.trim().isNotEmpty) {
      await controller.createWorktree(name.trim());
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.trailing,
    this.actions = const [],
  });

  final String title;
  final Widget child;
  final String? trailing;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ...actions,
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ChangeTile extends StatelessWidget {
  const _ChangeTile({required this.controller, required this.change});

  final CockpitController controller;
  final VcsFileStatus change;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (change.status) {
      VcsFileStatusStatus.added => theme.colorScheme.primary,
      VcsFileStatusStatus.deleted => theme.colorScheme.error,
      _ => theme.colorScheme.tertiary,
    };
    final selected = controller.inspectDiff?.file == change.file;
    return InkWell(
      onTap: () => controller.inspectFileDiff(change.file),
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
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                change.file,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
            Text(
              '+${change.additions} -${change.deletions}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: 'AppMono',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorktreeTile extends StatelessWidget {
  const _WorktreeTile({required this.controller, required this.worktree});

  final CockpitController controller;
  final WorktreeDirectory worktree;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final directory = '${worktree.directory}';
    final name = directory.split('/').last;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.folder_copy_outlined,
            size: 13,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Tooltip(
              message: directory,
              child: Text(
                name.isEmpty ? directory : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          if (worktree.strategy != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                worktree.strategy!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Remove worktree',
            onPressed: () => controller.removeWorktree(directory),
            icon: const Icon(Icons.delete_outline_rounded, size: 14),
          ),
        ],
      ),
    );
  }
}
