import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import 'cockpit_controller.dart';
import 'session_transfer.dart';
import 'theme.dart';
import 'widgets/agent_form_panel.dart';
import 'widgets/command_palette.dart';
import 'widgets/composer.dart';
import 'widgets/connect_screen.dart';
import 'widgets/connections_dialog.dart';
import 'widgets/files_panel.dart';
import 'widgets/git_panel.dart';
import 'widgets/inbox_strip.dart';
import 'widgets/inspector.dart';
import 'widgets/model_picker.dart';
import 'widgets/permission_banner.dart';
import 'widgets/persistent_terminals_panel.dart';
import 'widgets/session_explorer.dart';
import 'widgets/session_transfer_dialogs.dart';
import 'widgets/stats_panel.dart';
import 'widgets/terminal_panel.dart';
import 'widgets/transcript.dart';

/// Width below which the workbench switches to the narrow layout: the
/// activity rail and explorer move into a drawer, the inspector becomes an
/// end drawer, and the top bar condenses.
const double cockpitNarrowBreakpoint = 1024;

/// Root layout of the cockpit.
class CockpitShell extends StatefulWidget {
  const CockpitShell({super.key, required this.controller});

  final CockpitController controller;

  @override
  State<CockpitShell> createState() => _CockpitShellState();
}

class _CockpitShellState extends State<CockpitShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  InspectorTab _lastInspectorTab = InspectorTab.none;
  int _lastInspectorShows = 0;

  CockpitController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isConnected) {
          return ConnectScreen(controller: controller);
        }
        controller.onShowConnections = () {
          _showConnections(context, controller);
        };
        controller.onShowExport = () {
          _showExport(context, controller);
        };
        controller.onShowImport = () {
          _showImport(context, controller);
        };
        controller.onShowForms = () {
          showFormDialog(context, controller);
        };
        final narrow =
            MediaQuery.sizeOf(context).width < cockpitNarrowBreakpoint;
        _syncInspectorDrawer(narrow);
        final inspectorVisible = controller.inspectorTab != InspectorTab.none;
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
              if (controller.paletteVisible) {
                controller.hidePalette();
              } else {
                controller.showPalette();
              }
            },
            const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
                controller.newSession(),
            const SingleActivator(LogicalKeyboardKey.keyJ, meta: true): () =>
                controller.toggleTerminal(),
            const SingleActivator(
              LogicalKeyboardKey.keyI,
              meta: true,
              shift: true,
            ): () =>
                controller.toggleTheme(),
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              key: _scaffoldKey,
              drawer: narrow
                  ? Drawer(
                      width: 372,
                      child: _NarrowDrawer(controller: controller),
                    )
                  : null,
              endDrawer: narrow && inspectorVisible
                  ? Drawer(
                      width: 440,
                      child: InspectorPanel(controller: controller),
                    )
                  : null,
              body: Stack(
                children: [
                  Column(
                    children: [
                      _TopBar(controller: controller, narrow: narrow),
                      const Divider(height: 1),
                      Expanded(
                        child: Row(
                          children: [
                            if (!narrow) ...[
                              _ActivityRail(controller: controller),
                              const VerticalDivider(width: 1),
                              SizedBox(
                                width: 304,
                                child: _Explorer(controller: controller),
                              ),
                              const VerticalDivider(width: 1),
                            ],
                            Expanded(
                              child: _MainArea(
                                controller: controller,
                                narrow: narrow,
                              ),
                            ),
                            if (!narrow && inspectorVisible) ...[
                              const VerticalDivider(width: 1),
                              SizedBox(
                                width: 470,
                                child: InspectorPanel(controller: controller),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      _StatusBar(controller: controller),
                    ],
                  ),
                  if (controller.paletteVisible)
                    CommandPalette(controller: controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Opens the inspector end drawer on narrow layouts whenever the inspector
  /// tab changes or a new [CockpitController.showInspector] call arrives.
  void _syncInspectorDrawer(bool narrow) {
    final tab = controller.inspectorTab;
    final shows = controller.inspectorShows;
    final changed = tab != _lastInspectorTab || shows != _lastInspectorShows;
    _lastInspectorTab = tab;
    _lastInspectorShows = shows;
    if (!narrow || tab == InspectorTab.none || !changed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scaffoldKey.currentState?.openEndDrawer();
    });
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B7CF6), Color(0xFF4FC3F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.terminal_rounded, size: 16, color: Colors.white),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller, required this.narrow});

  final CockpitController controller;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      color: theme.panelBackground,
      padding: EdgeInsets.symmetric(horizontal: narrow ? 6 : 12),
      child: narrow ? _buildNarrow(context, theme) : _buildWide(context, theme),
    );
  }

  Widget _buildWide(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        const _Logo(),
        const SizedBox(width: 10),
        Text('OpenCode Cockpit', style: theme.textTheme.titleSmall),
        const SizedBox(width: 16),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final project in controller.projects)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _ProjectTab(
                      project: project,
                      selected: controller.activeProject?.id == project.id,
                      onTap: () => controller.selectProject(project),
                    ),
                  ),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Refresh projects',
          onPressed: () => controller.loadProjects(),
          icon: const Icon(Icons.refresh_rounded, size: 17),
        ),
        IconButton(
          tooltip: 'Command palette (\u2318K)',
          onPressed: controller.showPalette,
          icon: const Icon(Icons.rocket_launch_outlined, size: 17),
        ),
        IconButton(
          tooltip: 'Connections and settings',
          onPressed: () => _showConnections(context, controller),
          icon: const Icon(Icons.tune_rounded, size: 17),
        ),
        IconButton(
          tooltip: 'Toggle theme (\u2318\u21e7I)',
          onPressed: controller.toggleTheme,
          icon: Icon(
            controller.themeMode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            size: 17,
          ),
        ),
        IconButton(
          tooltip: 'Reconnect',
          onPressed: () => controller.connectLocal(),
          icon: const Icon(Icons.link_rounded, size: 17),
        ),
      ],
    );
  }

  Widget _buildNarrow(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Menu',
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu_rounded, size: 19),
        ),
        const _Logo(),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'OpenCode Cockpit',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
        ),
        if (controller.projects.isNotEmpty)
          _ProjectPicker(controller: controller),
        IconButton(
          tooltip: 'Command palette (\u2318K)',
          onPressed: controller.showPalette,
          icon: const Icon(Icons.rocket_launch_outlined, size: 17),
        ),
        IconButton(
          tooltip: 'Toggle theme (\u2318\u21e7I)',
          onPressed: controller.toggleTheme,
          icon: Icon(
            controller.themeMode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            size: 17,
          ),
        ),
        IconButton(
          tooltip: 'Reconnect',
          onPressed: () => controller.connectLocal(),
          icon: const Icon(Icons.link_rounded, size: 17),
        ),
      ],
    );
  }
}

/// Compact project switcher used by the narrow top bar.
class _ProjectPicker extends StatelessWidget {
  const _ProjectPicker({required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    final active = controller.activeProject;
    final name = active == null
        ? 'project'
        : active.name?.trim().isNotEmpty == true
        ? active.name!
        : active.canonical.split('/').last;
    return PopupMenuButton<Project>(
      tooltip: 'Switch project',
      onSelected: controller.selectProject,
      itemBuilder: (context) => [
        for (final project in controller.projects)
          CheckedPopupMenuItem(
            value: project,
            checked: project.id == active?.id,
            child: Text(
              project.name?.trim().isNotEmpty == true
                  ? project.name!
                  : project.canonical,
            ),
          ),
      ],
      child: _HeaderChip(icon: Icons.folder_outlined, label: name),
    );
  }
}

class _ProjectTab extends StatelessWidget {
  const _ProjectTab({
    required this.project,
    required this.selected,
    required this.onTap,
  });

  final Project project;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = project.name?.trim().isNotEmpty == true
        ? project.name!
        : project.canonical.split('/').last;
    return Tooltip(
      message: project.canonical,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_outlined,
                size: 13,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 7),
              Text(name, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityRail extends StatelessWidget {
  const _ActivityRail({required this.controller, this.onSelected});

  final CockpitController controller;

  /// Called after a rail action, e.g. to close the narrow-layout drawer.
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    void select(ExplorerTab tab) {
      controller.selectExplorerTab(tab);
      onSelected?.call();
    }

    return Container(
      width: 52,
      color: theme.railBackground,
      child: Column(
        children: [
          const SizedBox(height: 8),
          _RailButton(
            icon: Icons.forum_outlined,
            tooltip: 'Sessions',
            selected: controller.explorerTab == ExplorerTab.sessions,
            onTap: () => select(ExplorerTab.sessions),
          ),
          _RailButton(
            icon: Icons.folder_open_outlined,
            tooltip: 'Files',
            selected: controller.explorerTab == ExplorerTab.files,
            onTap: () => select(ExplorerTab.files),
          ),
          _RailButton(
            icon: Icons.account_tree_outlined,
            tooltip: 'Git',
            selected: controller.explorerTab == ExplorerTab.git,
            onTap: () => select(ExplorerTab.git),
          ),
          _RailButton(
            icon: Icons.dns_outlined,
            tooltip: 'Persistent terminals',
            selected: controller.explorerTab == ExplorerTab.terminals,
            onTap: () => select(ExplorerTab.terminals),
          ),
          _RailButton(
            icon: Icons.insights_outlined,
            tooltip: 'Statistics',
            selected: controller.explorerTab == ExplorerTab.stats,
            onTap: () => select(ExplorerTab.stats),
          ),
          const Spacer(),
          _RailButton(
            icon: Icons.terminal_rounded,
            tooltip: 'Toggle terminal (\u2318J)',
            selected: controller.terminalVisible,
            onTap: () {
              controller.toggleTerminal();
              onSelected?.call();
            },
          ),
          _RailButton(
            icon: Icons.difference_outlined,
            tooltip: 'Session changes',
            selected: controller.inspectorTab == InspectorTab.changes,
            onTap: () {
              if (controller.inspectorTab == InspectorTab.changes) {
                controller.showInspector(InspectorTab.none);
              } else {
                controller.showInspector(InspectorTab.changes);
                controller.loadSessionChanges();
              }
              onSelected?.call();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Rail + explorer for the narrow-layout drawer.
class _NarrowDrawer extends StatelessWidget {
  const _NarrowDrawer({required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          _ActivityRail(
            controller: controller,
            onSelected: () => Navigator.of(context).maybePop(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _Explorer(controller: controller)),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 38,
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _Explorer extends StatelessWidget {
  const _Explorer({required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).panelBackground,
      child: switch (controller.explorerTab) {
        ExplorerTab.sessions => SessionExplorer(controller: controller),
        ExplorerTab.files => FilesPanel(controller: controller),
        ExplorerTab.git => GitPanel(controller: controller),
        ExplorerTab.terminals => PersistentTerminalsPanel(
          terminals: controller.persistentTerminals,
          selectedID: controller.selectedPersistentID,
          loading: controller.loadingPersistentTerminals,
          onSelect: (terminal) => controller.attachPersistentTerminal(terminal),
          onCreate: () => controller.createPersistentTerminal(),
          onRefresh: () => controller.loadPersistentTerminals(),
          onKill: (terminal) => controller.killPersistentTerminal(terminal),
        ),
        ExplorerTab.stats => StatsPanel(controller: controller),
      },
    );
  }
}

class _MainArea extends StatelessWidget {
  const _MainArea({required this.controller, required this.narrow});

  final CockpitController controller;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SessionHeader(controller: controller, narrow: narrow),
        Expanded(child: _TranscriptHost(controller: controller)),
        if (controller.terminalVisible)
          SizedBox(
            height: narrow ? 200 : 280,
            child: TerminalPanel(controller: controller),
          ),
        InboxStrip(
          items: controller.inboxItems.whereType<SessionInboxInfo>().toList(),
          busy: controller.sending,
          onCancel: (item) => controller.cancelInboxItem(item),
          onDeliveryChanged: (item, delivery) =>
              controller.setInboxDelivery(item, delivery),
        ),
        PermissionBanner(controller: controller),
        CockpitComposer(
          controller: controller,
          enabled: controller.isConnected,
          busy: controller.activeBusy,
        ),
      ],
    );
  }
}

class _TranscriptHost extends StatefulWidget {
  const _TranscriptHost({required this.controller});

  final CockpitController controller;

  @override
  State<_TranscriptHost> createState() => _TranscriptHostState();
}

class _TranscriptHostState extends State<_TranscriptHost> {
  final ScrollController _scroll = ScrollController();
  var _wasNearBottom = true;
  var _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _scroll.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    final count = widget.controller.messages.length;
    if (count != _lastMessageCount) {
      _lastMessageCount = count;
      _wasNearBottom = _scroll.hasClients
          ? _scroll.position.maxScrollExtent - _scroll.position.pixels < 160
          : true;
    }
    if (!_wasNearBottom || !_scroll.hasClients) return;
    // While a message is streaming, follow it with a jump: continuous deltas
    // would restart an animation on every frame and stutter.
    final streaming = widget.controller.messages.any(
      (message) => message.streaming,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final target = _scroll.position.maxScrollExtent;
      if (streaming) {
        _scroll.jumpTo(target);
      } else {
        _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TranscriptView(
      messages: widget.controller.messages,
      loading: widget.controller.loadingMessages,
      hasSession: widget.controller.activeSession != null,
      scrollController: _scroll,
      hasOlder: widget.controller.olderMessagesCursor != null,
      loadingOlder: widget.controller.loadingOlderMessages,
      onLoadEarlier: () => widget.controller.loadOlderMessages(),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.controller, required this.narrow});

  final CockpitController controller;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = controller.activeSession;
    return Container(
      height: 52,
      color: theme.panelBackground,
      padding: EdgeInsets.symmetric(horizontal: narrow ? 10 : 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              session?.title?.trim().isNotEmpty == true
                  ? session!.title!
                  : session != null
                  ? 'Untitled session'
                  : 'No session selected',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
          ),
          if (session != null) ...[
            if (controller.agents.isNotEmpty)
              _AgentMenu(controller: controller, session: session),
            const SizedBox(width: 8),
            if (controller.models.isNotEmpty)
              _ModelMenu(controller: controller, session: session),
            const SizedBox(width: 8),
            if (controller.sessionForms.isNotEmpty)
              IconButton(
                tooltip: 'Agent question (${controller.sessionForms.length})',
                onPressed: () => showFormDialog(context, controller),
                icon: Badge(
                  label: Text('${controller.sessionForms.length}'),
                  child: const Icon(Icons.assignment_outlined, size: 17),
                ),
              ),
            IconButton(
              tooltip: 'Review changes in this session',
              onPressed: () {
                controller.showInspector(InspectorTab.changes);
                controller.loadSessionChanges();
              },
              icon: const Icon(Icons.rule_folder_outlined, size: 17),
            ),
            if (!narrow) ...[
              IconButton(
                tooltip: 'Fork session',
                onPressed: () => controller.forkSession(session),
                icon: const Icon(Icons.call_split_rounded, size: 17),
              ),
              IconButton(
                tooltip: 'Reload transcript',
                onPressed: () => controller.loadMessages(),
                icon: const Icon(Icons.refresh_rounded, size: 17),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _AgentMenu extends StatelessWidget {
  const _AgentMenu({required this.controller, required this.session});

  final CockpitController controller;
  final SessionInfo session;

  @override
  Widget build(BuildContext context) {
    final current = session.agent;
    return PopupMenuButton<String>(
      tooltip: 'Switch agent',
      onSelected: controller.switchAgent,
      itemBuilder: (context) => [
        for (final agent in controller.agents)
          CheckedPopupMenuItem(
            value: agent.id,
            checked: agent.id == current,
            child: Text(agent.name),
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
  const _ModelMenu({required this.controller, required this.session});

  final CockpitController controller;
  final SessionInfo session;

  @override
  Widget build(BuildContext context) {
    final current = session.model;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => showModelPicker(context, controller),
      child: _HeaderChip(
        icon: Icons.memory_rounded,
        label: current == null
            ? 'model'
            : '${current.providerID}/${current.id}',
      ),
    );
  }
}

Future<void> _showConnections(
  BuildContext context,
  CockpitController controller,
) async {
  final client = controller.client;
  if (client == null) return;
  await ConnectionsDialog.show(context, client);
}

Future<void> _showExport(
  BuildContext context,
  CockpitController controller,
) async {
  final session = controller.activeSession;
  if (session == null) return;
  String? path;
  if (sessionTransferUsesPaths) {
    path = await showSessionExportDialog(
      context,
      sessionID: '${session.id}',
      suggestedPath: suggestedExportPath('${session.id}'),
    );
    if (path == null || !context.mounted) return;
  }
  try {
    final written = await controller.exportActiveSession(path: path);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sessionTransferUsesPaths
              ? 'Exported transcript to $written'
              : 'Downloading transcript as $written',
        ),
      ),
    );
  } on Object catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export failed: ${CockpitController.describe(error)}'),
      ),
    );
  }
}

Future<void> _showImport(
  BuildContext context,
  CockpitController controller,
) async {
  String? path;
  if (sessionTransferUsesPaths) {
    path = await showSessionImportDialog(
      context,
      suggestedPath: suggestedImportPath(),
    );
    if (path == null || !context.mounted) return;
  }
  final String? json;
  try {
    json = await readSessionJson(path: path);
  } on Object catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Import failed: ${CockpitController.describe(error)}'),
      ),
    );
    return;
  }
  if (json == null || !context.mounted) return;
  final imported = await controller.importSessionFromJson(json);
  if (!context.mounted) return;
  if (imported != null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Imported session ${imported.id}')));
  } else if (controller.connectionError != null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(controller.connectionError!)));
  }
}

/// Opens the first pending agent form, if any.
Future<void> showFormDialog(
  BuildContext context,
  CockpitController controller,
) async {
  if (controller.activeForm == null) {
    final pending = controller.sessionForms;
    if (pending.isEmpty) return;
    await controller.openForm(pending.first);
  }
  final form = controller.activeForm;
  if (form == null || !context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
        child: SingleChildScrollView(
          child: AgentFormPanel(
            detail: form,
            onReply: (answer) {
              Navigator.of(dialogContext).pop();
              controller.replyForm(answer);
            },
            onCancel: () {
              Navigator.of(dialogContext).pop();
              controller.cancelActiveForm();
            },
          ),
        ),
      ),
    ),
  );
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
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.controller});

  final CockpitController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = controller.activeSession;
    final usage = session == null ? null : controller.usage[session.id];
    final tokens = usage?.tokens;
    final cost = usage?.cost ?? session?.cost;
    return Container(
      height: 28,
      color: theme.panelBackground,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.connectionError ??
                  '${controller.baseUrl} \u00b7 v${controller.serverVersion}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: controller.connectionError != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (controller.activeBusy)
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
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          if (tokens != null && cost != null) ...[
            const SizedBox(width: 14),
            Text(
              '${compactTokens(tokens.input)} in \u00b7 '
              '${compactTokens(tokens.output)} out \u00b7 '
              '\$${cost.toStringAsFixed(4)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(width: 14),
          Text(
            'sessions ${controller.rootSessions.length}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
