// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'package:schemantic/schemantic.dart';

part 'tools.g.dart';

/// Input of the `websearch` tool registered by the OpenCode plugin.
///
/// The tool is opt-in (`openCode(webSearchTool: true)`) and runs the search
/// through the OpenCode server, so it works with models from any Genkit
/// plugin — not just the `openCode` bridge.
@Schema()
abstract class $WebSearchToolInput {
  /// The search query.
  String get query;

  /// Optional web search provider id, overriding the server's default.
  String? get providerID;
}

/// One web search result.
@Schema()
abstract class $WebSearchToolResult {
  /// Result title (the URL when the provider returns no title).
  String get title;

  /// Result URL.
  String get url;

  /// Snippet or extracted content, when the provider returns one.
  String? get content;
}

/// Output of the `websearch` tool.
@Schema()
abstract class $WebSearchToolOutput {
  /// The provider that answered the search.
  String get provider;

  /// Results in provider order.
  List<$WebSearchToolResult> get results;
}
