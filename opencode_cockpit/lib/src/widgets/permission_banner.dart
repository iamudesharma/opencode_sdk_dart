import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import '../cockpit_controller.dart';

/// Pending permission requests for the active session.
class PermissionBanner extends StatelessWidget {
  const PermissionBanner({super.key, required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    final pending = controller.pendingPermissions;
    if (pending.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.4),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final request in pending)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Permission requested: ${request.action}',
                          style: theme.textTheme.labelLarge,
                        ),
                        if (request.resources.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                for (final resource in request.resources.take(
                                  4,
                                ))
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      resource,
                                      style: const TextStyle(
                                        fontFamily: 'AppMono',
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => controller.replyPermission(
                          request,
                          PermissionReply.reject,
                        ),
                        child: const Text('Reject'),
                      ),
                      OutlinedButton(
                        onPressed: () => controller.replyPermission(
                          request,
                          PermissionReply.once,
                        ),
                        child: const Text('Allow once'),
                      ),
                      FilledButton(
                        onPressed: () => controller.replyPermission(
                          request,
                          PermissionReply.always,
                        ),
                        child: const Text('Always allow'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
