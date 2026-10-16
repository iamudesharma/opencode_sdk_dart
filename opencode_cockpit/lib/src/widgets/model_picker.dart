import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import '../cockpit_controller.dart';
import '../theme.dart';

/// Opens the searchable model picker and switches the active session's model.
///
/// Returns the chosen [ModelRef], or null when the dialog was cancelled.
Future<ModelRef?> showModelPicker(
  BuildContext context,
  CockpitController controller,
) async {
  final session = controller.activeSession;
  if (session == null || controller.models.isEmpty) return null;
  final selected = await showDialog<ModelRef>(
    context: context,
    builder: (context) =>
        _ModelPickerDialog(models: controller.models, current: session.model),
  );
  if (selected == null) return null;
  await controller.switchModel(selected);
  return selected;
}

/// Search field over every `providerID/modelID` with a checkmark on the
/// session's current model.
class _ModelPickerDialog extends StatefulWidget {
  const _ModelPickerDialog({required this.models, required this.current});

  final List<ModelInfo> models;
  final ModelRef? current;

  @override
  State<_ModelPickerDialog> createState() => _ModelPickerDialogState();
}

class _ModelPickerDialogState extends State<_ModelPickerDialog> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ModelInfo> get _filtered {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return widget.models;
    return [
      for (final model in widget.models)
        if ('${model.providerID}/${model.modelID}'.toLowerCase().contains(
              query,
            ) ||
            model.name.toLowerCase().contains(query))
          model,
    ];
  }

  bool _isCurrent(ModelInfo model) =>
      model.modelID == widget.current?.id &&
      '${model.providerID}' == '${widget.current?.providerID}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;
    final query = _search.text.trim();
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 10, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Switch model',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    '${widget.models.length} available',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _search,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search provider/model\u2026',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () => setState(_search.clear),
                          icon: const Icon(Icons.close_rounded, size: 16),
                        ),
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(28),
                      child: Text(
                        'No models match "$query".',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final model = filtered[index];
                        final current = _isCurrent(model);
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            current
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 18,
                            color: current
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                          ),
                          title: Text(
                            '${model.providerID}/${model.modelID}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: kMonoTextStyle.copyWith(fontSize: 12.5),
                          ),
                          subtitle: model.name == model.modelID
                              ? null
                              : Text(
                                  model.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                          onTap: () => Navigator.of(context).pop(
                            ModelRef(
                              providerID: model.providerID,
                              id: model.modelID,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
