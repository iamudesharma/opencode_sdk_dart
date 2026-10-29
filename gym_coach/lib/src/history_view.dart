/// The reusable saved-plan list.
///
/// Shared by the desktop history dialog and the phone History tab; rows show
/// the title, when it was generated, the model and a typed/text badge, with
/// Load, Export and Delete actions.
library;

import 'package:flutter/material.dart';

import 'plan_export.dart';
import 'plan_store.dart';
import 'style.dart';

/// Lists saved plans with load, export and delete actions.
class PlanHistoryList extends StatefulWidget {
  /// Creates the list.
  const PlanHistoryList({
    super.key,
    required this.store,
    required this.onLoad,
    this.padding = const EdgeInsets.all(Insets.lg),
  });

  /// The plan store to read from.
  final PlanStore store;

  /// Called when the athlete loads a plan.
  final void Function(SavedPlan plan) onLoad;

  /// Padding around the list.
  final EdgeInsetsGeometry padding;

  @override
  State<PlanHistoryList> createState() => _PlanHistoryListState();
}

class _PlanHistoryListState extends State<PlanHistoryList> {
  late Future<List<SavedPlan>> _plans = widget.store.list();

  void _reload() => setState(() => _plans = widget.store.list());

  Future<void> _delete(SavedPlan plan) async {
    await widget.store.delete(plan.id);
    if (mounted) _reload();
  }

  Future<void> _export(SavedPlan plan) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final message = await exportPlanMarkdown(markdown: plan.markdown);
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<SavedPlan>>(
      future: _plans,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final plans = snapshot.data ?? const <SavedPlan>[];
        if (plans.isEmpty) {
          final tokens = context.fit;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: tokens.line),
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      size: 22,
                      color: tokens.dim,
                    ),
                  ),
                  const SizedBox(height: Insets.lg),
                  Text(
                    'Nothing saved yet.',
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: Insets.sm),
                  Text(
                    'Generated plans are kept here automatically, on this '
                    'device.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: tokens.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: widget.padding,
          itemCount: plans.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: Insets.sm),
          itemBuilder: (context, index) => _HistoryRow(
            plan: plans[index],
            onLoad: () => widget.onLoad(plans[index]),
            onExport: () => _export(plans[index]),
            onDelete: () => _delete(plans[index]),
          ),
        );
      },
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.plan,
    required this.onLoad,
    required this.onExport,
    required this.onDelete,
  });

  final SavedPlan plan;
  final VoidCallback onLoad;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.fit;
    final stamp = plan.createdAt.toLocal().toString().split('.').first;
    final typed = plan.structured != null;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        Insets.md,
        Insets.md,
        Insets.xs,
        Insets.md,
      ),
      onTap: onLoad,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: (typed ? tokens.accent : tokens.sage).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(Radii.sm),
              border: Border.all(
                color: (typed ? tokens.accent : tokens.sage).withValues(
                  alpha: 0.22,
                ),
              ),
            ),
            child: Icon(
              typed ? Icons.view_week_outlined : Icons.subject_rounded,
              size: 16,
              color: typed ? tokens.accent : tokens.sage,
            ),
          ),
          const SizedBox(width: Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$stamp · ${plan.modelId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kFitMonoStyle.copyWith(
                    fontSize: 9.5,
                    color: tokens.dim,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Insets.sm),
          StatChip(
            label: typed ? 'TYPED' : 'TEXT',
            dot: typed ? tokens.accent : tokens.sage,
          ),
          IconButton(
            tooltip: 'Load',
            visualDensity: VisualDensity.compact,
            onPressed: onLoad,
            icon: const Icon(Icons.arrow_outward_rounded, size: 17),
          ),
          IconButton(
            tooltip: 'Export',
            visualDensity: VisualDensity.compact,
            onPressed: onExport,
            icon: const Icon(Icons.ios_share, size: 17),
          ),
          IconButton(
            tooltip: 'Delete',
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 17),
          ),
        ],
      ),
    );
  }
}
