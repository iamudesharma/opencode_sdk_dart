import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencode_cockpit/src/cockpit_controller.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// Exercises the controller glue added for inbox, forms, pagination,
/// export/import, and persistent terminals against a mocked server.
void main() {
  late List<http.Request> requests;

  http.Response json(Object? body, {int status = 200}) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );

  http.Response empty() => http.Response('', 204);

  Map<String, Object?> sessionPayload({String id = 'ses_1'}) => {
    'id': id,
    'projectID': 'prj_1',
    'cost': 0.01,
    'tokens': {
      'input': 10,
      'output': 20,
      'reasoning': 0,
      'cache': {'read': 0, 'write': 0},
    },
    'time': {'created': 1, 'updated': 2},
    'location': {'directory': '/workspace'},
    'title': 'Integration session',
  };

  Map<String, Object?> inboxUserPayload({String id = 'inbox_1'}) => {
    'type': 'user',
    'id': id,
    'sessionID': 'ses_1',
    'time': {'created': 3},
    'payload': {'text': 'queued prompt'},
    'delivery': 'queue',
  };

  MockClient buildClient() => MockClient((request) async {
    requests.add(request);
    final path = request.url.path;
    if (path == '/api/info') {
      return json({
        'version': '2.0.28',
        'pid': 42,
        'urls': ['http://localhost:4096'],
        'paths': {'tmp': '/tmp'},
      });
    }
    if (path == '/api/project') {
      return json([
        {
          'id': 'prj_1',
          'canonical': '/workspace',
          'name': 'workspace',
          'commands': <String, Object?>{},
          'sandboxes': <Object?>[],
          'time': {'created': 1, 'updated': 2, 'active': 3},
        },
      ]);
    }
    if (path == '/api/session' && request.method == 'GET') {
      return json({
        'data': [sessionPayload()],
        'cursor': <String, Object?>{},
      });
    }
    if (path == '/api/session/ses_1/diff') {
      return json({
        'location': {'directory': '/workspace'},
        'data': [],
      });
    }
    if (path == '/api/agent') {
      return json({
        'location': {'directory': '/workspace'},
        'data': <Object?>[],
      });
    }
    if (path == '/api/model') {
      return json({
        'location': {'directory': '/workspace'},
        'data': <Object?>[],
      });
    }
    if (path == '/api/event') {
      return http.Response(
        '',
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    }
    if (path == '/api/experimental/session/stats') {
      return json({
        'data': {
          'range': {'from': 1.0, 'to': 2.0},
          'sessions': 1,
          'subagents': 0,
          'prompts': 1,
          'steps': 2,
          'tokens': {
            'input': 1,
            'output': 1,
            'reasoning': 0,
            'cache': {'read': 0, 'write': 0},
          },
          'cost': 0.0,
          'tools': {'mode': 'none'},
          'activeDays': 1,
          'streak': 1,
          'activity': <Object?>[],
          'models': <Object?>[],
        },
      });
    }
    if (path == '/api/session/ses_1/inbox') {
      return json({
        'data': [inboxUserPayload()],
      });
    }
    if (path == '/api/session/ses_1/inbox/inbox_1') {
      return request.method == 'DELETE' ? empty() : empty();
    }
    if (path == '/api/session/ses_1/form') {
      return json({
        'data': [
          {
            'id': 'form_1',
            'sessionID': 'ses_1',
            'title': 'Deploy?',
            'fields': <Object?>[],
          },
        ],
      });
    }
    if (path == '/api/session/ses_1/form/form_1') {
      return json({
        'data': {
          'id': 'form_1',
          'sessionID': 'ses_1',
          'title': 'Deploy?',
          'fields': [
            {
              'type': 'string',
              'key': 'target',
              'title': 'Target',
              'required': true,
            },
          ],
          'state': {'status': 'pending'},
        },
      });
    }
    if (path == '/api/session/ses_1/form/form_1/reply') {
      return empty();
    }
    if (path == '/api/session/ses_1/message') {
      final cursor = request.url.queryParameters['cursor'];
      if (cursor == null) {
        return json({
          'data': [
            {
              'id': 'msg_new',
              'type': 'user',
              'sessionID': 'ses_1',
              'time': {'created': 10},
              'text': 'newest',
            },
          ],
          'cursor': {'previous': 'page_2'},
        });
      }
      return json({
        'data': [
          {
            'id': 'msg_old',
            'type': 'user',
            'sessionID': 'ses_1',
            'time': {'created': 5},
            'text': 'older',
          },
          {
            'id': 'msg_new',
            'type': 'user',
            'sessionID': 'ses_1',
            'time': {'created': 10},
            'text': 'newest',
          },
        ],
        'cursor': <String, Object?>{},
      });
    }
    if (path == '/api/experimental/session/ses_1/export') {
      return json({
        'data': {'info': sessionPayload(), 'messages': <Object?>[]},
      });
    }
    if (path == '/api/experimental/session/import') {
      return json({'data': sessionPayload(id: 'ses_2')});
    }
    if (path == '/api/experimental/session/ses_1/terminal') {
      return json(<Object?>[]);
    }
    return json({'message': 'unhandled $path'}, status: 404);
  });

  Future<CockpitController> connected() async {
    final controller = CockpitController()..httpClientFactory = buildClient;
    await controller.connectTo(Uri.parse('http://localhost:4096'));
    expect(controller.connection, CockpitConnection.connected);
    return controller;
  }

  setUp(() => requests = []);

  test('connect loads projects and root sessions', () async {
    final controller = await connected();
    expect(controller.projects.single.id, 'prj_1');
    expect(controller.rootSessions.single.info.id, 'ses_1');
    controller.dispose();
  });

  test('openSession loads inbox and forms', () async {
    final controller = await connected();
    await controller.openSession(controller.rootSessions.single.info);
    expect(controller.inboxItems.single.id, 'inbox_1');
    expect(controller.sessionForms.single.title, 'Deploy?');
    controller.dispose();
  });

  test('inbox cancel and delivery update hit the API', () async {
    final controller = await connected();
    await controller.openSession(controller.rootSessions.single.info);
    final item = controller.inboxItems.single;
    await controller.setInboxDelivery(item, SessionInboxDelivery.steer);
    final patch = requests.lastWhere(
      (request) =>
          request.url.path == '/api/session/ses_1/inbox/inbox_1' &&
          request.method == 'PATCH',
    );
    expect(jsonDecode(patch.body), {'delivery': 'steer'});

    await controller.cancelInboxItem(item);
    expect(
      requests.any(
        (request) =>
            request.url.path == '/api/session/ses_1/inbox/inbox_1' &&
            request.method == 'DELETE',
      ),
      isTrue,
    );
    controller.dispose();
  });

  test('forms load, open, and reply with the answer map', () async {
    final controller = await connected();
    await controller.openSession(controller.rootSessions.single.info);
    await controller.openForm(controller.sessionForms.single);
    expect(controller.activeForm?.title, 'Deploy?');
    await controller.replyForm({'target': 'staging'});
    final reply = requests.lastWhere(
      (request) => request.url.path.endsWith('/form/form_1/reply'),
    );
    expect(jsonDecode(reply.body), {
      'answer': {'target': 'staging'},
    });
    expect(controller.activeForm, isNull);
    controller.dispose();
  });

  test('older messages are prepended without duplicates', () async {
    final controller = await connected();
    await controller.openSession(controller.rootSessions.single.info);
    expect(controller.messages.single.text, 'newest');
    expect(controller.olderMessagesCursor, 'page_2');

    await controller.loadOlderMessages();
    expect(controller.messages.map((message) => message.text).toList(), [
      'older',
      'newest',
    ]);
    expect(controller.olderMessagesCursor, isNull);
    controller.dispose();
  });

  test('export writes the transcript and import posts it back', () async {
    final controller = await connected();
    await controller.openSession(controller.rootSessions.single.info);
    final directory = Directory.systemTemp.createTempSync('cockpit-export');
    addTearDown(() => directory.deleteSync(recursive: true));
    final path = '${directory.path}/session.json';
    final written = await controller.exportActiveSession(path: path);
    final text = File(written).readAsStringSync();
    final decoded = asJsonMap(jsonDecode(text));
    expect(decoded['info'], isNotNull);

    await controller.importSessionFromJson(text);
    final imported = requests.lastWhere(
      (request) => request.url.path == '/api/experimental/session/import',
    );
    final body = asJsonMap(jsonDecode(imported.body));
    expect(body['info'], isNotNull);
    expect(body['messages'], isA<List<Object?>>());
    controller.dispose();
  });
}
