/// Web plan export: downloads the Markdown through a Blob + anchor.
library;

import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Downloads the plan as `gym_coach_plan_<ts>.md`.
Future<String> exportPlanMarkdownPlatform({required String markdown}) async {
  final name = 'gym_coach_plan_${DateTime.now().millisecondsSinceEpoch}';
  final blob = web.Blob(
    <JSAny>[markdown.toJS].toJS,
    web.BlobPropertyBag(type: 'text/markdown'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = '$name.md';
  anchor.click();
  web.URL.revokeObjectURL(url);
  return 'Downloaded $name.md';
}
