// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tools.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

/// Input of the `websearch` tool registered by the OpenCode plugin.
///
/// The tool is opt-in (`openCode(webSearchTool: true)`) and runs the search
/// through the OpenCode server, so it works with models from any Genkit
/// plugin — not just the `openCode` bridge.
base class WebSearchToolInput {
  /// Creates a [WebSearchToolInput] from a JSON map.
  factory WebSearchToolInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  WebSearchToolInput._(this._json);

  WebSearchToolInput({required String query, String? providerID}) {
    _json = {'query': query, 'providerID': ?providerID};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [WebSearchToolInput].
  static const SchemanticType<WebSearchToolInput> $schema =
      _WebSearchToolInputTypeFactory();

  /// The search query.
  String get query {
    return _json['query'] as String;
  }

  /// The search query.
  set query(String value) {
    _json['query'] = value;
  }

  /// Optional web search provider id, overriding the server's default.
  String? get providerID {
    return _json['providerID'] as String?;
  }

  /// Optional web search provider id, overriding the server's default.
  set providerID(String? value) {
    if (value == null) {
      _json.remove('providerID');
    } else {
      _json['providerID'] = value;
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [WebSearchToolInput] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _WebSearchToolInputTypeFactory
    extends SchemanticType<WebSearchToolInput> {
  const _WebSearchToolInputTypeFactory();

  @override
  WebSearchToolInput parse(Object? json) {
    return WebSearchToolInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'WebSearchToolInput',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'query': <String, Object?>{'type': 'string'},
        'providerID': <String, Object?>{'type': 'string'},
      },
      'required': ['query'],
    },
    dependencies: [],
  );
}

/// One web search result.
base class WebSearchToolResult {
  /// Creates a [WebSearchToolResult] from a JSON map.
  factory WebSearchToolResult.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  WebSearchToolResult._(this._json);

  WebSearchToolResult({
    required String title,
    required String url,
    String? content,
  }) {
    _json = {'title': title, 'url': url, 'content': ?content};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [WebSearchToolResult].
  static const SchemanticType<WebSearchToolResult> $schema =
      _WebSearchToolResultTypeFactory();

  /// Result title (the URL when the provider returns no title).
  String get title {
    return _json['title'] as String;
  }

  /// Result title (the URL when the provider returns no title).
  set title(String value) {
    _json['title'] = value;
  }

  /// Result URL.
  String get url {
    return _json['url'] as String;
  }

  /// Result URL.
  set url(String value) {
    _json['url'] = value;
  }

  /// Snippet or extracted content, when the provider returns one.
  String? get content {
    return _json['content'] as String?;
  }

  /// Snippet or extracted content, when the provider returns one.
  set content(String? value) {
    if (value == null) {
      _json.remove('content');
    } else {
      _json['content'] = value;
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [WebSearchToolResult] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _WebSearchToolResultTypeFactory
    extends SchemanticType<WebSearchToolResult> {
  const _WebSearchToolResultTypeFactory();

  @override
  WebSearchToolResult parse(Object? json) {
    return WebSearchToolResult._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'WebSearchToolResult',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'title': <String, Object?>{'type': 'string'},
        'url': <String, Object?>{'type': 'string'},
        'content': <String, Object?>{'type': 'string'},
      },
      'required': ['title', 'url'],
    },
    dependencies: [],
  );
}

/// Output of the `websearch` tool.
base class WebSearchToolOutput {
  /// Creates a [WebSearchToolOutput] from a JSON map.
  factory WebSearchToolOutput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  WebSearchToolOutput._(this._json);

  WebSearchToolOutput({
    required String provider,
    required List<WebSearchToolResult> results,
  }) {
    _json = {
      'provider': provider,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [WebSearchToolOutput].
  static const SchemanticType<WebSearchToolOutput> $schema =
      _WebSearchToolOutputTypeFactory();

  /// The provider that answered the search.
  String get provider {
    return _json['provider'] as String;
  }

  /// The provider that answered the search.
  set provider(String value) {
    _json['provider'] = value;
  }

  /// Results in provider order.
  List<WebSearchToolResult> get results {
    return (_json['results'] as List)
        .map((e) => WebSearchToolResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Results in provider order.
  set results(List<WebSearchToolResult> value) {
    _json['results'] = value.map((e) => e.toJson()).toList();
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [WebSearchToolOutput] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _WebSearchToolOutputTypeFactory
    extends SchemanticType<WebSearchToolOutput> {
  const _WebSearchToolOutputTypeFactory();

  @override
  WebSearchToolOutput parse(Object? json) {
    return WebSearchToolOutput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'WebSearchToolOutput',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'provider': <String, Object?>{'type': 'string'},
        'results': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{r'$ref': r'#/$defs/WebSearchToolResult'},
        },
      },
      'required': ['provider', 'results'],
    },
    dependencies: [WebSearchToolResult.$schema],
  );
}
