// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'package:genkit/plugin.dart';
import 'package:schemantic/schemantic.dart';

part 'embedders.g.dart';

/// Options for OpenAI embedding models (`POST /embeddings`).
///
/// `encoding_format` is deliberately absent: the only alternative to the
/// default is `base64`, which returns the vector as a string this client
/// cannot parse, so offering it would only let a caller break the call.
@Schema()
abstract class $OpenAIEmbedderOptions {
  /// Length of the returned vector.
  ///
  /// Only the `text-embedding-3-*` models accept this, and only to shorten:
  /// they are trained so that a prefix of the vector is still a usable
  /// embedding. Defaults to the model's full size.
  @IntegerField(minimum: 1)
  int? get dimensions;

  /// User identifier for abuse detection.
  String? get user;
}

/// Maximum inputs accepted in one `POST /embeddings` call.
///
/// A larger `embed` is split across requests rather than rejected, since a
/// corpus of more than 2048 documents is an ordinary thing to embed.
const int maxEmbeddingInputs = 2048;

/// Splits [inputs] into batches the host accepts in a single request.
Iterable<List<String>> embeddingBatches(List<String> inputs) sync* {
  for (var start = 0; start < inputs.length; start += maxEmbeddingInputs) {
    yield inputs.sublist(
      start,
      (start + maxEmbeddingInputs).clamp(0, inputs.length),
    );
  }
}

/// Flattens [documents] into the strings sent as `input`.
///
/// A document's text parts are joined with newlines; media parts are dropped
/// (there is no multimodal embedder here). A document that carries no text is
/// rejected rather than sent as an empty string.
List<String> embeddingInputs(List<DocumentData> documents) {
  return [
    for (var i = 0; i < documents.length; i++)
      _documentText(documents[i], index: i),
  ];
}

String _documentText(DocumentData document, {required int index}) {
  final text = document.content
      .where((part) => part.isText)
      .map((part) => part.text ?? '')
      .join('\n');
  if (text.trim().isEmpty) {
    throw GenkitException(
      'Document at index $index has no text content to embed. OpenAI '
      'embedders accept text only.',
      status: StatusCode.invalidArgument,
    );
  }
  return text;
}

/// One entry of the curated OpenAI embedder catalog.
final class EmbedderSpec {
  const EmbedderSpec({
    required this.dimensions,
    required this.dimensionsReducible,
  });

  /// The vector length the model returns by default.
  final int dimensions;

  /// Whether the model accepts a shorter `dimensions` override.
  final bool dimensionsReducible;
}

/// Curated embedder specs, used for `dimensions` validation only.
const Map<String, EmbedderSpec> curatedEmbedders = {
  'text-embedding-3-small': EmbedderSpec(
    dimensions: 1536,
    dimensionsReducible: true,
  ),
  'text-embedding-3-large': EmbedderSpec(
    dimensions: 3072,
    dimensionsReducible: true,
  ),
  'text-embedding-ada-002': EmbedderSpec(
    dimensions: 1536,
    dimensionsReducible: false,
  ),
};

/// Validates a requested [dimensions] against the curated catalog.
///
/// Unknown names are left to the host: there is no claim to check against.
void validateEmbedderDimensions(String embedderName, int? dimensions) {
  if (dimensions == null) return;
  final spec = curatedEmbedders[embedderName];
  if (spec == null) return;

  if (!spec.dimensionsReducible) {
    throw GenkitException(
      '$embedderName does not support the dimensions option; it always '
      'returns ${spec.dimensions} dimensions.',
      status: StatusCode.invalidArgument,
    );
  }
  if (dimensions < 1 || dimensions > spec.dimensions) {
    throw GenkitException(
      '$embedderName returns between 1 and ${spec.dimensions} dimensions; '
      'got $dimensions.',
      status: StatusCode.invalidArgument,
    );
  }
}

/// Whether [modelName] looks like an embedding model.
bool isEmbedderName(String modelName) {
  final name = modelName.toLowerCase();
  return name.contains('embedding') || name.contains('embed-');
}

/// Converts a decoded embeddings response into Genkit [Embedding]s.
///
/// Ordered by the `index` the host stamps on each vector rather than by
/// position, because the caller's list order is the only thing tying a vector
/// back to its document and the response is not documented to preserve it.
List<Embedding> toGenkitEmbeddings(
  Map<String, dynamic> response, {
  required int expectedCount,
}) {
  final data = response['data'];
  if (data is! List || data.length != expectedCount) {
    throw GenkitException(
      'The embeddings endpoint returned ${data is List ? data.length : 0} '
      'embeddings for $expectedCount input documents.',
      status: StatusCode.internal,
    );
  }

  final ordered = [...data]..sort((a, b) => _indexOf(a).compareTo(_indexOf(b)));
  return [
    for (final entry in ordered)
      Embedding(
        embedding: [
          for (final value in _vectorOf(entry)) value.toDouble(),
        ],
      ),
  ];
}

int _indexOf(Object? entry) =>
    entry is Map && entry['index'] is num ? (entry['index'] as num).toInt() : 0;

Iterable<num> _vectorOf(Object? entry) sync* {
  final embedding = entry is Map ? entry['embedding'] : null;
  if (embedding is! List) {
    throw GenkitException(
      'An embeddings response entry had no vector.',
      status: StatusCode.internal,
    );
  }
  for (final value in embedding) {
    if (value is num) yield value;
  }
}
