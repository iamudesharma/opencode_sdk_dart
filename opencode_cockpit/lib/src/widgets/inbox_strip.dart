import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// Compact strip of pending inputs (queued / steering) for the active session.
///
/// Renders one row per [items] entry: the kind icon, a one-line summary, a
/// tap-to-cycle `steer` / `queue` delivery toggle, and a cancel button. The
/// strip renders nothing when [items] is empty.
class InboxStrip extends StatelessWidget {
  const InboxStrip({
    super.key,
    required this.items,
    required this.onCancel,
    required this.onDeliveryChanged,
    this.busy = false,
  });

  /// Pending inputs admitted for the session, in display order.
  final List<SessionInboxInfo> items;

  /// Called with the pending input to drop when its cancel button is pressed.
  final void Function(SessionInboxInfo item) onCancel;

  /// Called when the user flips an input between `steer` and `queue`.
  final void Function(SessionInboxInfo item, SessionInboxDelivery delivery)
  onDeliveryChanged;

  /// Disables every row interaction while a request is in flight.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items)
            _InboxRow(
              item: item,
              busy: busy,
              onCancel: onCancel,
              onDeliveryChanged: onDeliveryChanged,
            ),
        ],
      ),
    );
  }
}

/// One-line human summary of an inbox item (used by the strip and tooltips).
String describeInboxItem(SessionInboxInfo item) => switch (item) {
  SessionInboxUser(:final payload) => payload.text,
  SessionInboxSynthetic(:final payload) => payload.text,
  SessionInboxCompaction(:final payload) => _describeCompaction(payload),
  SessionInboxMove(:final payload) => 'Move to ${_moveTarget(payload)}',
};

/// Icon matching the inbox item kind.
IconData inboxItemIcon(SessionInboxInfo item) => switch (item) {
  SessionInboxUser() => Icons.person_outline_rounded,
  SessionInboxSynthetic() => Icons.auto_awesome_outlined,
  SessionInboxCompaction() => Icons.compress_rounded,
  SessionInboxMove() => Icons.drive_file_move_outlined,
};

/// The compaction payload has no declared shape on the wire, so summarize a
/// string payload or a `reason` field when present and fall back to a label.
String _describeCompaction(Object? payload) {
  var reason = '';
  if (payload is String) {
    reason = payload.trim();
  } else if (payload is Map) {
    final value = payload['reason'];
    if (value is String) reason = value.trim();
  }
  return reason.isEmpty ? 'Compaction' : 'Compaction: $reason';
}

/// Prefers the absolute location, then the project-relative subpath.
String _moveTarget(SessionInboxMovePayload payload) =>
    payload.location.directory ??
    payload.subpath?.value ??
    payload.projectID.value;

class _InboxRow extends StatelessWidget {
  const _InboxRow({
    required this.item,
    required this.busy,
    required this.onCancel,
    required this.onDeliveryChanged,
  });

  final SessionInboxInfo item;
  final bool busy;
  final void Function(SessionInboxInfo item) onCancel;
  final void Function(SessionInboxInfo item, SessionInboxDelivery delivery)
  onDeliveryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = describeInboxItem(item);
    final current = item.delivery;
    final next = current == SessionInboxDelivery.steer
        ? SessionInboxDelivery.queue
        : SessionInboxDelivery.steer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            inboxItemIcon(item),
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Tooltip(
              message: description,
              child: Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Delivery: ${current.wire} (tap for ${next.wire})',
            child: InkWell(
              onTap: busy ? null : () => onDeliveryChanged(item, next),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(
                  current.wire,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            tooltip: 'Cancel pending input',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            iconSize: 14,
            onPressed: busy ? null : () => onCancel(item),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}
