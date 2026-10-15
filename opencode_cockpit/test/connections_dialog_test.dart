import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// `http` is exposed transitively through `opencode_sdk_dart`; the test uses
// its `MockClient` to drive the real client. Adding it to pubspec.yaml would
// require touching package metadata outside this change.
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart';
import 'package:opencode_cockpit/src/theme.dart';
import 'package:opencode_cockpit/src/widgets/connections_dialog.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

http.Response jsonResponse(Object? body, {int status = 200}) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

const location = {'directory': '/tmp'};

Future<void> pumpConnectionsDialog(
  WidgetTester tester,
  OpenCodeClient client,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildCockpitTheme(Brightness.dark),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => ConnectionsDialog.show(context, client),
              child: const Text('Open connections'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open connections'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('MCP tab lists servers and removes one', (tester) async {
    final requests = <http.Request>[];
    var servers = <Map<String, Object?>>[
      {
        'name': 'context7',
        'status': {'status': 'connected'},
      },
      {
        'name': 'sentry',
        'status': {'status': 'failed', 'error': 'timed out'},
      },
    ];
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        requests.add(request);
        switch ((request.method, request.url.path)) {
          case ('GET', '/api/mcp'):
            return jsonResponse({'location': location, 'data': servers});
          case ('DELETE', '/api/experimental/mcp/sentry'):
            servers = [servers.first];
            return http.Response('', 204);
        }
        return jsonResponse({'message': 'unexpected request'}, status: 404);
      }),
    );
    addTearDown(client.close);
    await pumpConnectionsDialog(tester, client);

    expect(find.text('context7'), findsOneWidget);
    expect(find.text('sentry'), findsOneWidget);
    expect(find.text('connected'), findsOneWidget);
    expect(find.text('failed'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('mcp_remove_sentry')));
    await tester.pumpAndSettle();
    expect(find.text('Remove sentry?'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    final deleted = requests.singleWhere((r) => r.method == 'DELETE');
    expect(deleted.url.path, '/api/experimental/mcp/sentry');
    expect(find.text('sentry'), findsNothing);
  });

  testWidgets('add server submits an encoded local config', (tester) async {
    final requests = <http.Request>[];
    final servers = <Map<String, Object?>>[];
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        requests.add(request);
        switch ((request.method, request.url.path)) {
          case ('GET', '/api/mcp'):
            return jsonResponse({'location': location, 'data': servers});
          case ('PUT', '/api/experimental/mcp/filesystem'):
            servers.add({
              'name': 'filesystem',
              'status': {'status': 'connected'},
            });
            return http.Response('', 204);
        }
        return jsonResponse({'message': 'unexpected request'}, status: 404);
      }),
    );
    addTearDown(client.close);
    await pumpConnectionsDialog(tester, client);

    await tester.tap(find.byKey(const ValueKey('mcp_add_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('mcp_add_name')),
      'filesystem',
    );
    await tester.enterText(
      find.byKey(const ValueKey('mcp_add_command')),
      'npx -y @modelcontextprotocol/server-filesystem /tmp',
    );
    await tester.tap(find.byKey(const ValueKey('mcp_add_save')));
    await tester.pumpAndSettle();

    final put = requests.singleWhere((r) => r.method == 'PUT');
    expect(put.url.path, '/api/experimental/mcp/filesystem');
    expect(jsonDecode(put.body), {
      'config': {
        'type': 'local',
        'command': [
          'npx',
          '-y',
          '@modelcontextprotocol/server-filesystem',
          '/tmp',
        ],
      },
    });
    expect(find.text('filesystem'), findsOneWidget);
  });

  testWidgets('Plugins tab lists plugins and checks updates', (tester) async {
    final requests = <http.Request>[];
    final plugins = [
      {
        'id': 'acme',
        'source': {'type': 'package', 'target': 'acme', 'version': '1.2.3'},
        'features': {'server': true, 'tui': true, 'rpc': true},
        'state': {'status': 'active'},
      },
    ];
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        requests.add(request);
        switch ((request.method, request.url.path)) {
          case ('GET', '/api/plugin'):
            return jsonResponse({'location': location, 'data': plugins});
          case ('POST', '/api/plugin/check'):
            return jsonResponse({'location': location, 'data': plugins});
        }
        return jsonResponse({'message': 'unexpected request'}, status: 404);
      }),
    );
    addTearDown(client.close);
    await pumpConnectionsDialog(tester, client);

    await tester.tap(find.text('Plugins'));
    await tester.pumpAndSettle();

    expect(find.text('acme'), findsOneWidget);
    expect(find.text('package'), findsOneWidget);
    expect(find.text('active'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('plugins_check')));
    await tester.pumpAndSettle();

    final checks = requests
        .where((r) => r.method == 'POST' && r.url.path == '/api/plugin/check')
        .toList();
    expect(checks, hasLength(1));
    expect(jsonDecode(checks.single.body), isEmpty);
  });

  testWidgets('Config tab renders documents and applies a shell', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        requests.add(request);
        switch ((request.method, request.url.path)) {
          case ('GET', '/api/config'):
            return jsonResponse([
              {
                'type': 'document',
                'path': '/Users/dev/.config/opencode/opencode.json',
                'info': {'shell': '/bin/zsh', 'model': 'gpt-5'},
              },
              {'type': 'directory', 'path': '/Users/dev/.config/opencode'},
            ]);
          case ('GET', '/api/config/shell'):
            return jsonResponse([
              {'path': '/bin/zsh', 'name': 'zsh', 'acceptable': true},
              {'path': '/bin/bash', 'name': 'bash', 'acceptable': false},
            ]);
          case ('PATCH', '/api/experimental/config'):
            return http.Response('', 204);
        }
        return jsonResponse({'message': 'unexpected request'}, status: 404);
      }),
    );
    addTearDown(client.close);
    await pumpConnectionsDialog(tester, client);

    await tester.tap(find.text('Config'));
    await tester.pumpAndSettle();

    expect(
      find.text('/Users/dev/.config/opencode/opencode.json'),
      findsOneWidget,
    );
    expect(find.text('/Users/dev/.config/opencode'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('config_shell_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('bash').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('config_apply_shell')));
    await tester.pumpAndSettle();

    final patch = requests.singleWhere((r) => r.method == 'PATCH');
    expect(patch.url.path, '/api/experimental/config');
    expect(jsonDecode(patch.body), {'shell': '/bin/bash'});
  });
}
