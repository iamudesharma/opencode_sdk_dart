import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import '../cockpit_controller.dart';

/// Explorer column when the Files tab is active.
class FilesPanel extends StatelessWidget {
  const FilesPanel({super.key, required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final root = controller.fileRoot;
    final segments = root.isEmpty ? const <String>[] : root.split('/');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Up one level',
                onPressed: root.isEmpty
                    ? null
                    : () => controller.loadDirectory(
                        segments.length <= 1
                            ? ''
                            : segments
                                  .sublist(0, segments.length - 1)
                                  .join('/'),
                      ),
                icon: const Icon(Icons.arrow_upward_rounded, size: 16),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => controller.loadDirectory(''),
                        child: Text(
                          controller.activeProject?.name ??
                              controller.activeLocation.directory ??
                              'workspace',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      for (final segment in segments) ...[
                        Text(
                          ' / ',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        Text(
                          segment,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: () => controller.loadDirectory(root),
                icon: const Icon(Icons.refresh_rounded, size: 16),
              ),
            ],
          ),
        ),
        if (controller.loadingFiles)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: controller.fileEntries.length,
            itemBuilder: (context, index) {
              final entry = controller.fileEntries[index];
              final path = '${entry.path}';
              final name = path.split('/').last;
              final isDirectory = entry.type == FileSystemEntryType.directory;
              final selected =
                  controller.selectedFilePath == path &&
                  controller.explorerTab == ExplorerTab.files;
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: isDirectory
                    ? () => controller.loadDirectory(path)
                    : () => controller.openFile(path),
                onSecondaryTapDown: (_) {
                  controller.insertReference(path);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.35,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDirectory ? Icons.folder_outlined : _fileIcon(name),
                        size: 14,
                        color: isDirectory
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      if (!isDirectory)
                        Icon(
                          Icons.add_rounded,
                          size: 13,
                          color: theme.colorScheme.outline,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
          child: Text(
            'Click to open \u00b7 right-click to insert @reference',
            maxLines: 2,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  static IconData _fileIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.dart')) return Icons.flutter_dash_outlined;
    if (lower.endsWith('.md')) return Icons.article_outlined;
    if (lower.endsWith('.json') ||
        lower.endsWith('.yaml') ||
        lower.endsWith('.yml')) {
      return Icons.data_object_rounded;
    }
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp')) {
      return Icons.image_outlined;
    }
    if (lower.endsWith('.sh') || lower.endsWith('.zsh')) {
      return Icons.terminal_rounded;
    }
    return Icons.description_outlined;
  }
}
