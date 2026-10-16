import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'chat_controller.dart';

/// First-run screen: discover the local service or enter a URL.
class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key, required this.controller});

  final ChatController controller;

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final TextEditingController _url = TextEditingController();
  var _manual = false;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _connectManual() async {
    final text = _url.text.trim();
    if (text.isEmpty) return;
    final uri = Uri.tryParse(text) ??
        Uri.parse('http://$text');
    await widget.controller.connectTo(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;
    final connecting = controller.connection == ChatConnection.connecting;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B7CF6), Color(0xFF4FC3F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.terminal_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('OpenCode Chat',
                            style: theme.textTheme.titleLarge),
                        Text(
                          'Talk to your local OpenCode server',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed:
                    connecting ? null : () => controller.connectLocal(),
                icon: connecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        kIsWeb ? Icons.lan_rounded : Icons.search_rounded,
                        size: 18,
                      ),
                label: Text(
                  connecting
                      ? 'Connecting\u2026'
                      : kIsWeb
                          ? 'Use this server'
                          : 'Find local service',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'or connect manually',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _url,
                enabled: !connecting,
                onTap: () => setState(() => _manual = true),
                onSubmitted: (_) => _connectManual(),
                decoration: InputDecoration(
                  hintText: kIsWeb
                      ? 'http://192.168.1.20:4096'
                      : 'http://localhost:4096',
                  prefixIcon: const Icon(Icons.link_rounded, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed:
                    connecting || !_manual ? null : () => _connectManual(),
                child: const Text('Connect'),
              ),
              if (controller.connectionError case final error?) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          size: 17, color: theme.colorScheme.error),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          error,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Text(
                kIsWeb
                    ? 'This app is served by your LAN host; requests go to '
                        'the same origin.'
                    : 'The local service is started automatically when needed.',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Physical keyboard shortcuts for the app window.
class AppShortcuts extends StatelessWidget {
  const AppShortcuts({super.key, required this.child, required this.controller});

  final Widget child;
  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
            controller.newSession(),
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}
