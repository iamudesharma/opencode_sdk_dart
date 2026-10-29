import 'package:flutter/material.dart';

import '../cockpit_controller.dart';
import '../theme.dart';

/// First screen: discover the local service or enter a URL.
class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key, required this.controller});

  final CockpitController controller;

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
    final uri = Uri.tryParse(text) ?? Uri.parse('http://$text');
    await widget.controller.connectTo(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;
    final connecting = controller.connection == CockpitConnection.connecting;
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        Icons.terminal_rounded,
                        size: 21,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OPENCODE',
                          style: theme.microLabel.copyWith(
                            fontSize: 8,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'Cockpit',
                          style: theme.textTheme.titleLarge!.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 42),
                Text(
                  'A quieter way into\nyour agent.',
                  style: theme.textTheme.displayMedium!.copyWith(
                    fontSize: 34,
                    height: 1.08,
                    letterSpacing: -0.9,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Projects, sessions, files, git and a real terminal — one '
                  'surface, no chrome fighting for attention.',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: connecting
                      ? null
                      : () => controller.connectLocal(),
                  icon: connecting
                      ? SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.arrow_forward_rounded, size: 17),
                  label: Text(
                    connecting ? 'Connecting…' : 'Find local service',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Text(
                      'OR CONNECT MANUALLY',
                      style: theme.microLabel.copyWith(fontSize: 8),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(height: 1, color: theme.hairline),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _url,
                  enabled: !connecting,
                  onTap: () => setState(() => _manual = true),
                  onSubmitted: (_) => _connectManual(),
                  style: kMonoTextStyle.copyWith(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'http://localhost:4096',
                    hintStyle: kMonoTextStyle.copyWith(
                      fontSize: 12,
                      color: theme.colorScheme.outline,
                    ),
                    prefixIcon: const Icon(Icons.link_rounded, size: 17),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: connecting || !_manual
                      ? null
                      : () => _connectManual(),
                  child: const Text('Connect'),
                ),
                if (controller.connectionError case final error?) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            error,
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: theme.colorScheme.error,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  'THE SHARED BACKGROUND SERVICE IS REUSED AND STARTED '
                  'AUTOMATICALLY WHEN NEEDED.',
                  style: theme.microLabel.copyWith(
                    fontSize: 8,
                    letterSpacing: 1.2,
                    height: 1.6,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
