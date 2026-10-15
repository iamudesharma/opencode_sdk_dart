/// Decoding helpers shared by generated model classes.
///
/// The helpers throw [OpenCodeDecodeException] with a dotted [path] whenever a
/// payload does not match the contract, so decoding failures point directly at
/// the offending field.
library;

import 'dart:convert';

import 'errors.dart';

/// A JSON object as produced by `jsonDecode`.
typedef JsonMap = Map<String, Object?>;

/// Casts [value] to a JSON object or throws [OpenCodeDecodeException].
JsonMap asJsonMap(Object? value, {String? path}) {
  if (value is Map) {
    if (value is JsonMap) return value;
    return value.cast<String, Object?>();
  }
  throw OpenCodeDecodeException('Expected a JSON object', path: path);
}

/// Casts [value] to a JSON array or throws [OpenCodeDecodeException].
List<Object?> asJsonList(Object? value, {String? path}) {
  if (value is List) return value;
  throw OpenCodeDecodeException('Expected a JSON array', path: path);
}

/// Casts [value] to a string or throws [OpenCodeDecodeException].
String asJsonString(Object? value, {String? path}) {
  if (value is String) return value;
  throw OpenCodeDecodeException('Expected a string', path: path);
}

/// Casts [value] to an int or throws [OpenCodeDecodeException].
int asJsonInt(Object? value, {String? path}) {
  if (value is int) return value;
  if (value is double && value == value.roundToDouble()) return value.toInt();
  throw OpenCodeDecodeException('Expected an integer', path: path);
}

/// Casts [value] to a double or throws [OpenCodeDecodeException].
double asJsonDouble(Object? value, {String? path}) {
  if (value is num) return value.toDouble();
  throw OpenCodeDecodeException('Expected a number', path: path);
}

/// Casts [value] to a bool or throws [OpenCodeDecodeException].
bool asJsonBool(Object? value, {String? path}) {
  if (value is bool) return value;
  throw OpenCodeDecodeException('Expected a boolean', path: path);
}

/// Reads a required object property and casts it with [asJsonMap].
JsonMap decodeMap(JsonMap json, String key) => asJsonMap(json[key], path: key);

/// Reads a required array property and casts it with [asJsonList].
List<Object?> decodeList(JsonMap json, String key) =>
    asJsonList(json[key], path: key);

/// Reads a required string property.
String decodeString(JsonMap json, String key) =>
    asJsonString(json[key], path: key);

/// Reads a required integer property.
int decodeInt(JsonMap json, String key) => asJsonInt(json[key], path: key);

/// Reads a required number property.
double decodeNumber(JsonMap json, String key) =>
    asJsonDouble(json[key], path: key);

/// Reads a required boolean property.
bool decodeBool(JsonMap json, String key) => asJsonBool(json[key], path: key);

/// Reads an optional object property.
JsonMap? decodeOptionalMap(JsonMap json, String key) {
  final value = json[key];
  if (value == null) return null;
  return asJsonMap(value, path: key);
}

/// Reads an optional array property.
List<Object?>? decodeOptionalList(JsonMap json, String key) {
  final value = json[key];
  if (value == null) return null;
  return asJsonList(value, path: key);
}

/// Reads an optional string property.
String? decodeOptionalString(JsonMap json, String key) {
  final value = json[key];
  if (value == null) return null;
  return asJsonString(value, path: key);
}

/// Reads an optional integer property.
int? decodeOptionalInt(JsonMap json, String key) {
  final value = json[key];
  if (value == null) return null;
  return asJsonInt(value, path: key);
}

/// Reads an optional number property.
double? decodeOptionalNumber(JsonMap json, String key) {
  final value = json[key];
  if (value == null) return null;
  return asJsonDouble(value, path: key);
}

/// Reads an optional boolean property.
bool? decodeOptionalBool(JsonMap json, String key) {
  final value = json[key];
  if (value == null) return null;
  return asJsonBool(value, path: key);
}

/// Unwraps values that may be JSON-encoded strings containing JSON.
///
/// Some streaming endpoints send JSON payloads embedded inside a JSON string.
/// This helper transparently decodes one level of that embedding.
Object? unwrapEmbeddedJson(Object? value) {
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        return jsonDecode(trimmed);
      } on FormatException {
        return value;
      }
    }
  }
  return value;
}
