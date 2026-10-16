/// Exports a generated plan as a Markdown file, per platform.
library;

import 'plan_export_stub.dart'
    if (dart.library.io) 'plan_export_io.dart'
    if (dart.library.js_interop) 'plan_export_web.dart';

/// Writes [markdown] somewhere the athlete can keep it.
///
/// Desktop: writes `~/Downloads/gym_coach_plan_<ts>.md` (falling back to the
/// home directory) and returns `'Exported to <path>'`.
///
/// Web: downloads the file through a Blob and anchor and returns
/// `'Downloaded <name>.md'`.
Future<String> exportPlanMarkdown({required String markdown}) =>
    exportPlanMarkdownPlatform(markdown: markdown);
