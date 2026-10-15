import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import 'chat_controller.dart';
import 'chat_transcript.dart';
import 'composer.dart';
import 'connect_screen.dart';
import 'permission_banner.dart';
import 'session_sidebar.dart';

/// Root layout: sidebar plus transcript, or the connect flow.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (!controller.isConnected) {
            return ConnectScreen(controller: controller);
          }
          return AppShortcuts(
            controller: controller,
            child: Row(
              children: [
                SizedBox(
                  width: 292,
                  child: SessionSidebar(
                    controller: controller,
                    onNewChat: () => controller.newSession(),
                    onOpenSession: (session) =>
                        controller.openSession(session),
                    onRefresh: () => controller.refreshSessions(),
                    onReconnect: () => controller.connectLocal(),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Column(
                    children: [
                      _ChatHeader(controller: controller),
                      Expanded(child: ChatTranscript(controller: controller)),
                      PermissionBanner(controller: controller),
                      Composer(
                        enabled: controller.isConnected,
                        busy: controller.activeBusy,
                        onSubmit: (text) => controller.send(text),
                        onInterrupt: () => controller.interrupt(),
                      ),
                      _StatusBar(controller: controller),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = controller.activeSession;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              session?.title?.trim().isNotEmpty == true
                  ? session!.title!
                  : session != null
                      ? 'Untitled session'
                      : 'No session',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
          ),
          if (session != null) ...[
            if (controller.agents.isNotEmpty)
              _AgentMenu(controller: controller),
            const SizedBox(width: 10),
            if (controller.models.isNotEmpty)
              _ModelMenu(controller: controller),
            const SizedBox(width: 10),
            Text(
              session.id,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontFamily: 'AppMono',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AgentMenu extends StatelessWidget {
  const _AgentMenu({required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    final current = controller.activeSession?.agent;
    return PopupMenuButton<String>(
      tooltip: 'Switch agent',
      onSelected: controller.switchAgent,
      itemBuilder: (context) => [
        for (final agent in controller.agents)
          PopupMenuItem(
            value: agent.id,
            child: Row(
              children: [
                if (agent.id == current)
                  const Icon(Icons.check_rounded, size: 15)
                else
                  const SizedBox(width: 15),
                const SizedBox(width: 8),
                Text(agent.name),
              ],
            ),
          ),
      ],
      child: _HeaderChip(
        icon: Icons.smart_toy_outlined,
        label: current ?? 'agent',
      ),
    );
  }
}

class _ModelMenu extends StatelessWidget {
  const _ModelMenu({required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    final current = controller.activeSession?.model;
    return PopupMenuButton<ModelRef>(
      tooltip: 'Switch model',
      onSelected: controller.switchModel,
      itemBuilder: (context) => [
        for (final model in controller.models.take(80))
          PopupMenuItem(
            value: ModelRef(
              providerID: model.providerID,
              id: model.modelID,
            ),
            child: Row(
              children: [
                if (model.modelID == current?.id)
                  const Icon(Icons.check_rounded, size: 15)
                else
                  const SizedBox(width: 15),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${model.providerID}/${model.modelID}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: _HeaderChip(
        icon: Icons.memory_rounded,
        label: current == null
            ? 'model'
            : '${current.providerID}/${current.id}',
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = controller.activeSession;
    final usage = session == null ? null : controller.usage[session.id];
    final tokens = usage?.tokens;
    final cost = usage?.cost ?? session?.cost;
    return Container(
      height: 30,
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (controller.connectionError case final error?)
            Expanded(
              child: Text(
                error,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            )
          else if (controller.activeBusy)
            Row(
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Working\u2026',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            )
          else
            const Spacer(),
          if (tokens != null && cost != null)
            Text(
              '${_compact(tokens.input)} in '
              '\u00b7 ${_compact(tokens.output)} out '
              '\u00b7 \$${cost.toStringAsFixed(4)}',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  static String _compact(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.round().toString();
  }
}
