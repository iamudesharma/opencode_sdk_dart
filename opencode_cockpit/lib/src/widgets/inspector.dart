import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import '../cockpit_controller.dart';
import '../theme.dart';
import 'diff_view.dart';
import 'transcript.dart' show MonoBlock;

/// Right-hand inspector: file viewer, diff viewer, or session changes list.
class InspectorPanel extends StatelessWidget {
  const InspectorPanel({super.key, required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.panelBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InspectorHeader(controller: controller),
          const Divider(height: 1),
          Expanded(
            child: switch (controller.inspectorTab) {
              InspectorTab.file => _FileView(controller: controller),
              InspectorTab.diff => _DiffView(controller: controller),
              InspectorTab.changes => _ChangesView(controller: controller),
              InspectorTab.none => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }
}

class _InspectorHeader extends StatelessWidget {
  const _InspectorHeader({required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = switch (controller.inspectorTab) {
      InspectorTab.file => controller.selectedFilePath ?? 'File',
      InspectorTab.diff => controller.inspectDiff?.file ?? 'Diff',
      InspectorTab.changes => 'Session changes',
      InspectorTab.none => 'Inspector',
    };
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            switch (controller.inspectorTab) {
              InspectorTab.file => Icons.description_outlined,
              InspectorTab.diff => Icons.difference_outlined,
              InspectorTab.changes => Icons.rule_folder_outlined,
              InspectorTab.none => Icons.info_outline,
            },
            size: 15,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Tooltip(
              message: title,
              child: Text(
                title,
                style: const TextStyle(fontFamily: 'AppMono', fontSize: 12.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (controller.inspectorTab == InspectorTab.file &&
              controller.selectedFilePath != null)
            IconButton(
              tooltip: 'Insert @reference',
              onPressed: () =>
                  controller.insertReference(controller.selectedFilePath!),
              icon: const Icon(Icons.alternate_email_rounded, size: 16),
            ),
          IconButton(
            tooltip: 'Close inspector',
            onPressed: () => controller.showInspector(InspectorTab.none),
            icon: const Icon(Icons.close_rounded, size: 16),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _FileView extends StatelessWidget {
  const _FileView({required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bytes = controller.selectedFileBytes;
    final text = controller.selectedFileText;
    if (text == null && bytes == null) {
      return Center(
        child: Text(
          controller.selectedFilePath == null
              ? 'Pick a file from the Files panel'
              : 'Loading\u2026',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    if (text == null && controller.selectedFileIsImage && bytes != null) {
      return InteractiveViewer(child: Center(child: Image.memory(bytes)));
    }
    if (text == null && controller.selectedFileIsBinary && bytes != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.data_object_rounded,
              size: 32,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 10),
            Text(
              'Binary file (${bytes.length} bytes)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    final source = text ?? '';
    final lineCount = '\n'.allMatches(source).length + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            color: theme.codeBackground,
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lineCount > 1)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var line = 1; line <= lineCount; line++)
                            Text(
                              '$line',
                              style: TextStyle(
                                fontFamily: 'AppMono',
                                fontSize: 11.8,
                                height: 1.45,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 10, 12, 10),
                      child: SelectableText(
                        source,
                        style: TextStyle(
                          fontFamily: 'AppMono',
                          fontSize: 11.8,
                          height: 1.45,
                          color: theme.codeForeground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiffView extends StatelessWidget {
  const _DiffView({required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    final diff = controller.inspectDiff;
    if (diff == null) {
      return const SizedBox.shrink();
    }
    return DiffView(diff: diff);
  }
}

class _ChangesView extends StatelessWidget {
  const _ChangesView({required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final changes = controller.sessionChanges;
    if (changes.isEmpty) {
      return Center(
        child: Text(
          'This session has not changed files yet',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'FILES TOUCHED BY THIS SESSION',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        for (final diff in changes)
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => controller.inspectSessionDiff(diff),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    switch (diff.status) {
                      FileDiffInfoStatus.added => Icons.add_circle_outline,
                      FileDiffInfoStatus.deleted => Icons.remove_circle_outline,
                      _ => Icons.edit_outlined,
                    },
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      diff.file,
                      style: const TextStyle(
                        fontFamily: 'AppMono',
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '+${diff.additions}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF4ADE80),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '-${diff.deletions}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A compact message part preview reused by the inspector (kept for future
/// file-diff rendering inside transcripts).
class InspectorMonoPreview extends StatelessWidget {
  const InspectorMonoPreview({
    super.key,
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => MonoBlock(title: title, text: text);
}
