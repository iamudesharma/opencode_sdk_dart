import 'dart:convert';

import 'package:http/http.dart' as http;

http.Response jsonResponse(Object? body, {int status = 200}) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

Map<String, Object?> sessionPayload({String id = 'ses_1'}) => {
  'id': id,
  'projectID': 'prj_1',
  'cost': 0.25,
  'tokens': {
    'input': 10,
    'output': 20,
    'reasoning': 0,
    'cache': {'read': 0, 'write': 0},
  },
  'time': {'created': 1, 'updated': 2},
  'location': {'directory': '/workspace'},
  'title': 'hello',
};

Map<String, Object?> userMessagePayload({required String id}) => {
  'id': id,
  'time': {'created': 1},
  'type': 'user',
  'text': 'hi',
};

Map<String, Object?> inboxUserPayload({String id = 'msg_1'}) => {
  'id': id,
  'sessionID': 'ses_1',
  'time': {'created': 1},
  'payload': {'text': 'hi'},
  'delivery': 'steer',
};
