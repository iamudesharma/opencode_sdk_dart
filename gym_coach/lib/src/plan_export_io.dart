/// `dart:io` plan export: writes the Markdown into the Downloads folder.
library;

import 'dart:io';

/// Writes the plan into `~/Downloads` (or `$HOME` when it does not exist).
Future<String> exportPlanMarkdownPlatform({required String markdown}) async {
  final home = Platform.environment['HOME'] ?? Directory.systemTemp.path;
  var directory = Directory('$home/Downloads');
  if (!directory.existsSync()) directory = Directory(home);
  final file = File(
    '${directory.path}/gym_coach_plan_'
    '${DateTime.now().millisecondsSinceEpoch}.md',
  );
  await file.create(recursive: true);
  await file.writeAsString(markdown);
  return 'Exported to ${file.path}';
}
