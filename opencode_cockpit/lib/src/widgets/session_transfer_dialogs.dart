import 'package:flutter/material.dart';

/// Asks for a destination path for `session.export`; null when cancelled.
///
/// [sessionID] identifies the exported session for the caller; the dialog
/// itself is path-only and pre-fills the field with [suggestedPath].
Future<String?> showSessionExportDialog(
  BuildContext context, {
  required String sessionID,
  required String suggestedPath,
}) {
  return _showTransferDialog(
    context,
    title: 'Export session',
    explanation: 'Writes the projected session transcript as JSON.',
    confirmLabel: 'Export',
    suggestedPath: suggestedPath,
  );
}

/// Asks for a source path for `session.import`; null when cancelled.
Future<String?> showSessionImportDialog(
  BuildContext context, {
  required String suggestedPath,
}) {
  return _showTransferDialog(
    context,
    title: 'Import session',
    explanation: 'Reads a previously exported transcript file.',
    confirmLabel: 'Import',
    suggestedPath: suggestedPath,
  );
}

Future<String?> _showTransferDialog(
  BuildContext context, {
  required String title,
  required String explanation,
  required String confirmLabel,
  required String suggestedPath,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TransferDialog(
      title: title,
      explanation: explanation,
      confirmLabel: confirmLabel,
      suggestedPath: suggestedPath,
    ),
  );
}

class _TransferDialog extends StatefulWidget {
  const _TransferDialog({
    required this.title,
    required this.explanation,
    required this.confirmLabel,
    required this.suggestedPath,
  });

  final String title;
  final String explanation;
  final String confirmLabel;
  final String suggestedPath;

  @override
  State<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<_TransferDialog> {
  late final TextEditingController _path;

  @override
  void initState() {
    super.initState();
    _path = TextEditingController(text: widget.suggestedPath);
  }

  @override
  void dispose() {
    _path.dispose();
    super.dispose();
  }

  String get _trimmedPath => _path.text.trim();

  void _confirm() {
    if (_trimmedPath.isEmpty) return;
    Navigator.of(context).pop(_trimmedPath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.explanation,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _path,
              autofocus: true,
              style: const TextStyle(fontFamily: 'AppMono', fontSize: 12),
              decoration: const InputDecoration(
                hintText: '/path/to/session.json',
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _confirm(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _trimmedPath.isEmpty ? null : _confirm,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
