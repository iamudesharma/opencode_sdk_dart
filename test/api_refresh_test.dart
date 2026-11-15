import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:test/test.dart';

http.Response _json(Object? body, {int status = 200}) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

OpenCodeClient _client(
  Future<http.Response> Function(http.Request request) handler,
) =>
    OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient(handler),
    );

void main() {
  test('eventTypeFilter matches exact types, wildcards and the marker', () {
    OpenCodeEvent event(String type) =>
        OpenCodeEvent(type: type, data: const {}, raw: const {});

    final filter = eventTypeFilter(['session.idle', 'rpc.*'])!;
    expect(filter(event('session.idle')), isTrue);
    expect(filter(event('session.created')), isFalse);
    expect(filter(event('rpc.acme.updated')), isTrue);
    expect(filter(event('server.connected')), isTrue);

    final sessionFilter = eventTypeFilter(['session.*'])!;
    expect(sessionFilter(event('session.text.delta')), isTrue);
    expect(sessionFilter(event('pty.created')), isFalse);

    expect(eventTypeFilter(null), isNull);
    final empty = eventTypeFilter(const <String>[])!;
    expect(empty(event('session.idle')), isFalse);
    expect(empty(event('server.connected')), isTrue);
  });

  test('LocationRef round-trips workspaceID', () {
    final ref = LocationRef.fromJson({
      'directory': '/workspace',
      'workspaceID': 'ws_1',
    });
    expect(ref.directory, '/workspace');
    expect(ref.workspaceID, 'ws_1');
    expect(ref.toJson(), {
      'directory': '/workspace',
      'workspaceID': 'ws_1',
    });
  });

  test('model.list repeats model type query values', () async {
    late http.Request captured;
    final client = _client((request) async {
      captured = request;
      return _json({
        'location': {'directory': '/workspace'},
        'data': <Object?>[],
      });
    });
    addTearDown(client.close);

    await client.model.list(types: ['chat', 'image']);

    expect(captured.url.path, '/api/model');
    expect(captured.url.queryParametersAll['types'], <String>['chat', 'image']);
  });

  test('session.list sends a typed parentID', () async {
    late http.Request captured;
    final client = _client((request) async {
      captured = request;
      return _json({'data': <Object?>[], 'cursor': <String, Object?>{}});
    });
    addTearDown(client.close);

    await client.session.list(parentID: SessionID('ses_parent'));

    expect(captured.url.queryParameters['parentID'], 'ses_parent');
  });

  test('voice.models decodes the model catalog', () async {
    late http.Request captured;
    final client = _client((request) async {
      captured = request;
      return _json({
        'data': {
          'models': [
            {
              'model': 'voice-1',
              'provider': 'openai',
              'transports': ['websocket'],
              'available': true,
            },
          ],
          'default': 'voice-1',
        },
      });
    });
    addTearDown(client.close);

    final response = await client.voice.models();

    expect(captured.url.path, '/api/experimental/voice/models');
    expect(response.data.models.single.model, 'voice-1');
    expect(
      response.data.models.single.transports.single,
      VoiceTransportType.websocket,
    );
    expect(response.data.defaultValue, 'voice-1');
  });

  test('schedule.create serializes typed when, if and ends values', () async {
    late http.Request captured;
    final client = _client((request) async {
      captured = request;
      return _json({
        'data': {
          'id': 'sch_1',
          'when': {'type': 'in', 'in': '1h'},
          'tz': 'UTC',
          'action': {'type': 'prompt', 'prompt': 'wake up'},
          'status': 'active',
          'runCount': 0,
          'time': {'created': 1, 'updated': 2},
        },
      });
    });
    addTearDown(client.close);

    final schedule = await client.experimental.schedule.create(
      sessionID: SessionID('ses_1'),
      when: ScheduleWhenIn(inValue: ScheduleDuration('1h')),
      ifValue: ScheduleConditionShell(run: 'true'),
      ends: ScheduleEnds(times: 3),
      prompt: 'wake up',
    );

    expect(captured.url.path, '/api/experimental/schedule');
    final body = jsonDecode(captured.body) as Map<String, Object?>;
    expect(body['when'], {'type': 'in', 'in': '1h'});
    expect(body['if'], {'type': 'shell', 'run': 'true'});
    expect(body['ends'], {'times': 3});
    expect(schedule.id, 'sch_1');
    expect(schedule.status, ScheduleStatus.active);
  });

  test('usage.limits decodes workspace limits', () async {
    late http.Request captured;
    final client = _client((request) async {
      captured = request;
      return _json({
        'location': {'directory': '/workspace'},
        'data': {
          'workspace': {
            'id': 'ws_1',
            'name': 'Workspace',
            'usageURL': '/usage'
          },
          'budgets': <Object?>[],
        },
      });
    });
    addTearDown(client.close);

    final limits = await client.usage.limits();

    expect(captured.url.path, '/api/experimental/usage/limits');
    expect(limits.data.workspace.id, 'ws_1');
    expect(limits.data.budgets, isEmpty);
  });

  test('permission.saved.update sends the changed fields', () async {
    late http.Request captured;
    final client = _client((request) async {
      captured = request;
      return _json({
        'data': {
          'id': 'perm_1',
          'projectID': 'prj_1',
          'action': 'allow',
          'resource': 'bash',
          'time': {'created': 1, 'updated': 2},
        },
      });
    });
    addTearDown(client.close);

    await client.permission.saved.update(
      id: PermissionSavedID('perm_1'),
      action: 'deny',
    );

    expect(captured.url.path, '/api/permission/saved/perm_1');
    expect(jsonDecode(captured.body), {'action': 'deny'});
  });
}
