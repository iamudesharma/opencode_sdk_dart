/// Fallback plan export for platforms with no file system or downloads.
library;

/// No export target exists on this platform.
Future<String> exportPlanMarkdownPlatform({required String markdown}) async =>
    throw UnsupportedError('Plan export is not supported on this platform.');
