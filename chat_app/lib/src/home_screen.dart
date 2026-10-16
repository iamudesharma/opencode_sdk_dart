import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import 'app_theme.dart';
import 'chat_controller.dart';
import 'chat_transcript.dart';
import 'composer.dart';
import 'connect_screen.dart';
import 'permission_banner.dart';
import 'session_sidebar.dart';

/// Width below which the sessions sidebar collapses into a drawer.
const double kSidebarBreakpoint = 760;

/// Root layout: sidebar plus transcript, or the connect flow.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final ChatController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isConnected) {
          return Scaffold(body: ConnectScreen(controller: controller));
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < kSidebarBreakpoint;
            final sidebar = SessionSidebar(
              controller: controller,
              onNewChat: () {
                if (narrow) Navigator.of(context).pop();
                controller.newSession();
              },
              onOpenSession: (session) {
                if (narrow) Navigator.of(context).pop();
                controller.openSession(session);
              },
              onRefresh: () => controller.refreshSessions(),
              onReconnect: () => controller.connectLocal(),
            );
            return Scaffold(
              key: _scaffoldKey,
              drawer: narrow ? Drawer(width: 292, child: sidebar) : null,
              body: AppShortcuts(
                controller: controller,
                child: Row(
                  children: [
                    if (!narrow && !_sidebarCollapsed) ...[
                      SizedBox(width: 292, child: sidebar),
                      const VerticalDivider(width: 1),
                    ],
                    Expanded(
                      child: Column(
                        children: [
                          _ChatHeader(
                            controller: controller,
                            narrow: narrow,
                            sidebarCollapsed: _sidebarCollapsed,
                            onOpenSidebar: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                            onToggleSidebar: () => setState(
                              () => _sidebarCollapsed = !_sidebarCollapsed,
                            ),
                          ),
                          Expanded(
                            child: ChatTranscript(controller: controller),
                          ),
                          PermissionBanner(controller: controller),
                          Composer(
                            enabled: controller.isConnected,
                            busy: controller.activeBusy,
                            onSubmit: (text, files) =>
                                controller.send(text, files: files),
                            onInterrupt: () => controller.interrupt(),
                          ),
                          _StatusBar(controller: controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.controller,
    required this.narrow,
    required this.sidebarCollapsed,
    required this.onOpenSidebar,
    required this.onToggleSidebar,
  });

  final ChatController controller;
  final bool narrow;
  final bool sidebarCollapsed;
  final VoidCallback onOpenSidebar;
  final VoidCallback onToggleSidebar;

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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            tooltip: narrow
                ? 'Sessions'
                : sidebarCollapsed
                    ? 'Show sessions'
                    : 'Hide sessions',
            onPressed: narrow ? onOpenSidebar : onToggleSidebar,
            icon: Icon(
              narrow || sidebarCollapsed
                  ? Icons.menu_rounded
                  : Icons.menu_open_rounded,
              size: 20,
            ),
          ),
          const SizedBox(width: 6),
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
            const SizedBox(width: 8),
            if (controller.models.isNotEmpty)
              _ModelPickerButton(controller: controller),
            if (!narrow) ...[
              const SizedBox(width: 10),
              Text(
                session.id,
                style: monoCopy(
                  theme.textTheme.labelSmall!,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ],
          const SizedBox(width: 4),
          _ThemeToggle(controller: controller),
        ],
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: controller.themeMode,
      builder: (context, mode, _) {
        final dark = mode == ThemeMode.dark;
        return IconButton(
          tooltip: dark ? 'Switch to light theme' : 'Switch to dark theme',
          onPressed: controller.toggleThemeMode,
          icon: Icon(
            dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: 19,
          ),
        );
      },
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

/// Opens the searchable model picker dialog.
class _ModelPickerButton extends StatelessWidget {
  const _ModelPickerButton({required this.controller});

  final ChatController controller;

  Future<void> _open(BuildContext context) async {
    final selected = await showDialog<ModelRef>(
      context: context,
      builder: (context) => _ModelPickerDialog(
        models: controller.models,
        current: controller.activeSession?.model,
      ),
    );
    if (selected == null) return;
    await controller.switchModel(selected);
  }

  @override
  Widget build(BuildContext context) {
    final current = controller.activeSession?.model;
    return Tooltip(
      message: 'Switch model',
      child: InkWell(
        key: const ValueKey('model-picker-button'),
        borderRadius: BorderRadius.circular(8),
        onTap: () => _open(context),
        child: _HeaderChip(
          icon: Icons.memory_rounded,
          label: current == null
              ? 'model'
              : '${current.providerID}/${current.id}',
        ),
      ),
    );
  }
}

/// Dialog listing every enabled model with a search field.
class _ModelPickerDialog extends StatefulWidget {
  const _ModelPickerDialog({required this.models, this.current});

  final List<ModelInfo> models;
  final ModelRef? current;

  @override
  State<_ModelPickerDialog> createState() => _ModelPickerDialogState();
}

class _ModelPickerDialogState extends State<_ModelPickerDialog> {
  final TextEditingController _query = TextEditingController();
  var _filtered = <ModelInfo>[];

  @override
  void initState() {
    super.initState();
    _filtered = widget.models;
    _query.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _query.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.models
          : [
              for (final model in widget.models)
                if (_modelKey(model).contains(query)) model,
            ];
    });
  }

  static String _modelKey(ModelInfo model) =>
      '${model.providerID}/${model.modelID}'.toLowerCase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = widget.current;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 10, 6),
              child: Row(
                children: [
                  Icon(
                    Icons.memory_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Text('Select model', style: theme.textTheme.titleSmall),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                key: const ValueKey('model-picker-search'),
                controller: _query,
                autofocus: true,
                style: theme.textTheme.bodySmall,
                decoration: InputDecoration(
                  hintText: 'Search provider/model',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: _filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Text(
                          'No models match.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final model = _filtered[index];
                        final selected = current != null &&
                            current.providerID == model.providerID &&
                            current.id == model.modelID;
                        final label = '${model.providerID}/${model.modelID}';
                        return ListTile(
                          key: ValueKey('model-option-$label'),
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          leading: Icon(
                            selected
                                ? Icons.check_rounded
                                : Icons.memory_rounded,
                            size: 17,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                          ),
                          title: Text(
                            label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          subtitle: model.name == label
                              ? null
                              : Text(
                                  model.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
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
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
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
