import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import '../theme.dart';

/// Manage MCP servers, plugins, and the effective configuration.
class ConnectionsDialog extends StatefulWidget {
  const ConnectionsDialog({super.key, required this.client});

  final OpenCodeClient client;

  /// Opens the dialog over the current route.
  static Future<void> show(BuildContext context, OpenCodeClient client) {
    return showDialog<void>(
      context: context,
      builder: (context) => ConnectionsDialog(client: client),
    );
  }

  @override
  State<ConnectionsDialog> createState() => _ConnectionsDialogState();
}

class _ConnectionsDialogState extends State<ConnectionsDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 640,
        height: 520,
        child: DefaultTabController(
          length: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.cable_rounded,
                      size: 17,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connections',
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close_rounded, size: 16),
                    ),
                  ],
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(height: 40, text: 'MCP'),
                  Tab(height: 40, text: 'Plugins'),
                  Tab(height: 40, text: 'Config'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _McpTab(client: widget.client),
                    _PluginsTab(client: widget.client),
                    _ConfigTab(client: widget.client),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MCP servers
// ---------------------------------------------------------------------------

enum _McpServerType { local, remote }

class _McpTab extends StatefulWidget {
  const _McpTab({required this.client});

  final OpenCodeClient client;

  @override
  State<_McpTab> createState() => _McpTabState();
}

class _McpTabState extends State<_McpTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commandController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  List<McpServer>? _servers;
  bool _loading = true;
  bool _busy = false;
  bool _adding = false;
  _McpServerType _type = _McpServerType.local;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commandController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final response = await widget.client.mcp.list();
      if (!mounted) return;
      setState(() {
        _servers = response.data;
        _error = null;
        _loading = false;
      });
    } on OpenCodeApiException catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = failure.message;
        _loading = false;
      });
    } catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = '$failure';
        _loading = false;
      });
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      await _refresh();
    } on OpenCodeApiException catch (failure) {
      if (!mounted) return;
      setState(() => _error = failure.message);
    } catch (failure) {
      if (!mounted) return;
      setState(() => _error = '$failure');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitAdd() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a server name.');
      return;
    }
    final ExperimentalMcpAddInputConfig config;
    if (_type == _McpServerType.local) {
      final command = _commandController.text
          .trim()
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList(growable: false);
      if (command.isEmpty) {
        setState(() => _error = 'Enter a command line.');
        return;
      }
      config = McpLocalConfigEncoded(command: command);
    } else {
      final url = _urlController.text.trim();
      if (url.isEmpty) {
        setState(() => _error = 'Enter a server URL.');
        return;
      }
      config = McpRemoteConfigEncoded(url: url);
    }
    await _run(() async {
      await widget.client.mcp.add(server: name, config: config);
      if (!mounted) return;
      setState(() {
        _adding = false;
        _nameController.clear();
        _commandController.clear();
        _urlController.clear();
      });
    });
  }

  Future<void> _remove(McpServer server) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${server.name}?'),
        content: const Text(
          'The server is stopped and removed from the runtime set until '
          'the next restart.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(() => widget.client.mcp.remove(server: server.name));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading && _servers == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final servers = _servers ?? const <McpServer>[];
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (_error != null)
          _ErrorBanner(
            message: _error!,
            onDismiss: () => setState(() => _error = null),
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                'MCP SERVERS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.8),
                ),
              ),
            TextButton.icon(
              key: const ValueKey('mcp_add_button'),
              onPressed: _busy
                  ? null
                  : () => setState(() => _adding = !_adding),
              icon: const Icon(Icons.add_rounded, size: 15),
              label: const Text('Add server'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (_adding) _buildAddForm(theme),
        if (servers.isEmpty && !_adding)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              'No MCP servers configured.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final server in servers) _buildServerRow(theme, server),
      ],
    );
  }

  Widget _buildAddForm(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'NEW SERVER',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('mcp_add_name'),
            controller: _nameController,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. filesystem',
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<_McpServerType>(
            key: const ValueKey('mcp_add_type'),
            segments: const [
              ButtonSegment(value: _McpServerType.local, label: Text('local')),
              ButtonSegment(
                value: _McpServerType.remote,
                label: Text('remote'),
              ),
            ],
            selected: {_type},
            showSelectedIcon: false,
            onSelectionChanged: _busy
                ? null
                : (selection) => setState(() => _type = selection.first),
          ),
          const SizedBox(height: 8),
          if (_type == _McpServerType.local)
            TextField(
              key: const ValueKey('mcp_add_command'),
              controller: _commandController,
              enabled: !_busy,
              decoration: const InputDecoration(
                labelText: 'Command',
                hintText: 'npx -y @modelcontextprotocol/server-filesystem',
              ),
            )
          else
            TextField(
              key: const ValueKey('mcp_add_url'),
              controller: _urlController,
              enabled: !_busy,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com/mcp',
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                key: const ValueKey('mcp_add_cancel'),
                onPressed: _busy ? null : () => setState(() => _adding = false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 6),
              FilledButton(
                key: const ValueKey('mcp_add_save'),
                onPressed: _busy ? null : _submitAdd,
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServerRow(ThemeData theme, McpServer server) {
    final status = server.status;
    final color = _mcpStatusColor(theme, status.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
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
            Icons.dns_outlined,
            size: 15,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              server.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 6),
          _StatusChip(
            label: status.status.replaceAll('_', ' '),
            color: color,
            message: switch (status) {
              McpStatusFailed(:final error) => error,
              McpStatusNeedsAuth(:final error) => error,
              _ => null,
            },
          ),
          const SizedBox(width: 4),
          TextButton(
            key: ValueKey('mcp_connect_${server.name}'),
            style: _rowButtonStyle,
            onPressed: _busy
                ? null
                : () => _run(
                    () => widget.client.mcp.connect(server: server.name),
                  ),
            child: const Text('Connect'),
          ),
          TextButton(
            key: ValueKey('mcp_disconnect_${server.name}'),
            style: _rowButtonStyle,
            onPressed: _busy
                ? null
                : () => _run(
                    () => widget.client.mcp.disconnect(server: server.name),
                  ),
            child: const Text('Disconnect'),
          ),
          IconButton(
            key: ValueKey('mcp_remove_${server.name}'),
            tooltip: 'Remove ${server.name}',
            visualDensity: VisualDensity.compact,
            onPressed: _busy ? null : () => _remove(server),
            icon: const Icon(Icons.delete_outline_rounded, size: 15),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plugins
// ---------------------------------------------------------------------------

class _PluginsTab extends StatefulWidget {
  const _PluginsTab({required this.client});

  final OpenCodeClient client;

  @override
  State<_PluginsTab> createState() => _PluginsTabState();
}

class _PluginsTabState extends State<_PluginsTab> {
  List<PluginInfo>? _plugins;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final response = await widget.client.plugin.list();
      if (!mounted) return;
      setState(() {
        _plugins = response.data;
        _error = null;
        _loading = false;
      });
    } on OpenCodeApiException catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = failure.message;
        _loading = false;
      });
    } catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = '$failure';
        _loading = false;
      });
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      await _refresh();
    } on OpenCodeApiException catch (failure) {
      if (!mounted) return;
      setState(() => _error = failure.message);
    } catch (failure) {
      if (!mounted) return;
      setState(() => _error = '$failure');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkUpdates() async {
    await _run(() async {
      final response = await widget.client.plugin.check(target: null);
      if (!mounted) return;
      setState(() => _plugins = response.data);
    });
  }

  Future<void> _updateAll() async {
    final plugins = _plugins ?? const <PluginInfo>[];
    final targets = [
      for (final plugin in plugins)
        if (plugin.source case PluginSourcePackage(:final target)) target,
    ];
    if (targets.isEmpty) {
      setState(() => _error = 'No package plugins to update.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update all plugins?'),
        content: Text(
          '${targets.length} package ${targets.length == 1 ? 'plugin' : 'plugins'} '
          'will be updated to their latest versions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(() => widget.client.plugin.update(targets: targets));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading && _plugins == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final plugins = _plugins ?? const <PluginInfo>[];
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (_error != null)
          _ErrorBanner(
            message: _error!,
            onDismiss: () => setState(() => _error = null),
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                'PLUGINS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.8),
                ),
              ),
            TextButton(
              key: const ValueKey('plugins_check'),
              onPressed: _busy ? null : _checkUpdates,
              child: const Text('Check updates'),
            ),
            const SizedBox(width: 4),
            OutlinedButton(
              key: const ValueKey('plugins_update_all'),
              onPressed: _busy ? null : _updateAll,
              child: const Text('Update all'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (plugins.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              'No plugins loaded.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final plugin in plugins) _buildPluginRow(theme, plugin),
      ],
    );
  }

  Widget _buildPluginRow(ThemeData theme, PluginInfo plugin) {
    final active = plugin.state.status == 'active';
    final name = _pluginName(plugin);
    final detail = switch (plugin.source) {
      PluginSourcePackage(:final target, :final version) =>
        version == null ? target : '$target@$version',
      PluginSourceLocal(:final path) => path,
      PluginSourceBuiltin() => null,
      PluginSourceSdk() => null,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
            Icons.extension_outlined,
            size: 15,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (detail != null && detail != name) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: 'AppMono',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          _StatusChip(
            label: plugin.source.type,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(width: 6),
          _StatusChip(
            label: plugin.state.status,
            color: active ? const Color(0xFF2FA96B) : theme.colorScheme.error,
            message: switch (plugin.state) {
              PluginStateFailed(:final error) => error,
              _ => null,
            },
          ),
        ],
      ),
    );
  }

  String _pluginName(PluginInfo plugin) {
    final id = plugin.id;
    if (id != null && id.isNotEmpty) return id;
    return switch (plugin.source) {
      PluginSourcePackage(:final target) => target,
      PluginSourceLocal(:final path) => path,
      PluginSourceBuiltin() => 'builtin plugin',
      PluginSourceSdk() => 'sdk plugin',
    };
  }
}

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

class _ConfigTab extends StatefulWidget {
  const _ConfigTab({required this.client});

  final OpenCodeClient client;

  @override
  State<_ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<_ConfigTab> {
  List<ConfigEntry>? _entries;
  List<ConfigShellOption>? _shells;
  String? _selectedShell;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final entries = await widget.client.config.get();
      final shells = await widget.client.config.shells();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _shells = shells;
        _selectedShell = _pickShell(shells, _selectedShell);
        _error = null;
        _loading = false;
      });
    } on OpenCodeApiException catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = failure.message;
        _loading = false;
      });
    } catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = '$failure';
        _loading = false;
      });
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      await _refresh();
    } on OpenCodeApiException catch (failure) {
      if (!mounted) return;
      setState(() => _error = failure.message);
    } catch (failure) {
      if (!mounted) return;
      setState(() => _error = '$failure');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _pickShell(List<ConfigShellOption> shells, String? current) {
    if (current != null && shells.any((shell) => shell.path == current)) {
      return current;
    }
    for (final shell in shells) {
      if (shell.acceptable) return shell.path;
    }
    return shells.isEmpty ? null : shells.first.path;
  }

  Future<void> _applyShell() async {
    final shell = _selectedShell;
    if (shell == null) return;
    await _run(() => widget.client.config.update(shell: shell));
  }

  Future<void> _reloadConfiguration() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reload configuration?'),
        content: const Text(
          'Every loaded location is shut down and rebuilt. Pending '
          'permissions and forms are cancelled; running sessions continue '
          'with fresh services at the next step boundary.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reload'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(() => widget.client.location.reload());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading && _entries == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final entries = _entries ?? const <ConfigEntry>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Row(
            children: [
              Expanded(child: _buildShellSelector(theme)),
              const SizedBox(width: 8),
              FilledButton(
                key: const ValueKey('config_apply_shell'),
                onPressed: _busy || _selectedShell == null ? null : _applyShell,
                child: const Text('Apply shell'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'CONFIGURATION',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 1.8),
                  ),
                ),
              OutlinedButton.icon(
                key: const ValueKey('config_reload'),
                onPressed: _busy ? null : _reloadConfiguration,
                icon: const Icon(Icons.restart_alt_rounded, size: 15),
                label: const Text('Reload configuration'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            children: [
              if (_error != null)
                _ErrorBanner(
                  message: _error!,
                  onDismiss: () => setState(() => _error = null),
                ),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Text(
                    'No configuration documents.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              for (final entry in entries) _buildEntryCard(theme, entry),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShellSelector(ThemeData theme) {
    final shells = _shells ?? const <ConfigShellOption>[];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: DropdownButton<String>(
        key: const ValueKey('config_shell_dropdown'),
        value: _selectedShell,
        isExpanded: true,
        borderRadius: BorderRadius.circular(10),
        underline: const SizedBox.shrink(),
        hint: Text(
          'Select a shell',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        items: [
          for (final shell in shells)
            DropdownMenuItem<String>(
              value: shell.path,
              child: Row(
                children: [
                  Icon(
                    shell.acceptable
                        ? Icons.check_circle_rounded
                        : Icons.remove_circle_outline_rounded,
                    size: 13,
                    color: shell.acceptable
                        ? const Color(0xFF2FA96B)
                        : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(shell.name, style: theme.textTheme.bodySmall),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shell.path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: 'AppMono',
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (!shell.acceptable)
                    Text(
                      'unavailable',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
        ],
        onChanged: _busy
            ? null
            : (value) => setState(() => _selectedShell = value),
      ),
    );
  }

  Widget _buildEntryCard(ThemeData theme, ConfigEntry entry) {
    final preview = switch (entry) {
      ConfigDocumentEncoded(:final info) => JsonEncoder.withIndent(
        '  ',
      ).convert(info.toJson()),
      ConfigDirectoryEncoded() => null,
    };
    final path = switch (entry) {
      ConfigDocumentEncoded(:final path) => path,
      ConfigDirectoryEncoded(:final path) => path,
    };
    final isDirectory = entry is ConfigDirectoryEncoded;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isDirectory
                    ? Icons.folder_outlined
                    : Icons.description_outlined,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  path?.toString() ?? '(unnamed document)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'AppMono',
                    color: theme.codeForeground,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(label: entry.type, color: theme.colorScheme.tertiary),
            ],
          ),
          if (preview != null) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: theme.codeBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: SelectableText(
                  preview,
                  style: TextStyle(
                    fontFamily: 'AppMono',
                    fontSize: 11.5,
                    height: 1.4,
                    color: theme.codeForeground,
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

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

final ButtonStyle _rowButtonStyle = TextButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 8),
  minimumSize: const Size(0, 28),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: VisualDensity.compact,
);

Color _mcpStatusColor(ThemeData theme, String status) => switch (status) {
  'connected' => const Color(0xFF2FA96B),
  'pending' => const Color(0xFFD79B00),
  'failed' => theme.colorScheme.error,
  'needs_auth' => const Color(0xFFE07B39),
  _ => theme.colorScheme.outline,
};

/// Inline error container rendered when an SDK call fails.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, this.onDismiss});

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 15,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onDismiss,
              borderRadius: BorderRadius.circular(4),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small colored status pill used for MCP and plugin states.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color, this.message});

  final String label;
  final Color color;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
    if (message == null || message!.isEmpty) return chip;
    return Tooltip(message: message!, child: chip);
  }
}
