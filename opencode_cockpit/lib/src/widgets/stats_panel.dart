import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import '../cockpit_controller.dart';
import '../theme.dart';
import 'transcript.dart' show compactTokens;

/// Explorer column when the Stats tab is active.
class StatsPanel extends StatelessWidget {
  const StatsPanel({super.key, required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = controller.stats;
    if (stats == null) {
      return Center(
        child: controller.loadingStats
            ? const CircularProgressIndicator(strokeWidth: 2)
            : Text(
                'No statistics yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
      );
    }
    final tools = switch (stats.tools) {
      SessionStatsToolsDetail(:final totals, :final usage) => (
        totals: totals,
        usage: usage,
      ),
      SessionStatsToolsSummary(:final totals) => (totals: totals, usage: null),
      _ => null,
    };
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'USAGE SUMMARY',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        _MetricRow(
          metrics: [
            _Metric('Sessions', '${stats.sessions}'),
            _Metric('Subagents', '${stats.subagents}'),
            _Metric('Prompts', '${stats.prompts}'),
            _Metric('Steps', '${stats.steps}'),
          ],
        ),
        const SizedBox(height: 8),
        _MetricRow(
          metrics: [
            _Metric('Input', compactTokens(stats.tokens.input)),
            _Metric('Output', compactTokens(stats.tokens.output)),
            _Metric('Cost', '\$${stats.cost.toStringAsFixed(3)}'),
            _Metric('Streak', '${stats.streak}d'),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'TOOLS',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        if (tools == null)
          Text(
            'No tool activity',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  '${tools.totals.calls} calls \u00b7 '
                  '${tools.totals.succeeded} ok \u00b7 '
                  '${tools.totals.failed} failed',
                  maxLines: 2,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final usage in tools.usage ?? const <SessionStatsToolUsage>[])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          usage.name,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${usage.succeeded}/${usage.calls}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: kMonoFontFamily,
                          fontFamilyFallback: kMonoFontFallback,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: usage.calls == 0
                          ? 0
                          : usage.succeeded / usage.calls,
                      minHeight: 4,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 18),
        Text(
          'RECENT ACTIVITY',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        _ActivityChart(activity: stats.activity),
      ],
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value);

  final String label;
  final String value;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metrics});

  final List<_Metric> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        for (var index = 0; index < metrics.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(metrics[index].value, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    metrics[index].label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({required this.activity});

  final List<SessionStatsActivity> activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (activity.isEmpty) {
      return Text(
        'No activity recorded',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final recent = activity.length > 21
        ? activity.sublist(activity.length - 21)
        : activity;
    final maxSteps = recent
        .map((entry) => entry.steps)
        .fold<int>(1, (a, b) => a > b ? a : b);
    return SizedBox(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final entry in recent) ...[
            Expanded(
              child: Tooltip(
                message: '${entry.date}: ${entry.steps} steps',
                child: Container(
                  height: 8 + 48 * (entry.steps / maxSteps),
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: entry.steps == 0
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.primary.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
