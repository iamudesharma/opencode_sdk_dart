// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Generates the typed Dart surface of the OpenCode V2 HTTP API from
/// `openapi/openapi.json`.
///
/// The generator emits:
///
/// * `lib/src/generated/models.dart` (library with parts) containing every
///   schema: branded scalar extension types, enums, data classes, sealed
///   union hierarchies, `LocatedResponse<T>`, and the structured exception
///   decoder;
/// * `lib/src/generated/resources/<tag>_resource.dart` for every OpenAPI tag;
/// * `lib/src/generated/client.dart` assembling `OpenCodeClient`.
///
/// Run with `dart run tool/generate.dart` from the package root.
Future<void> main() async {
  final specFile = File('openapi/openapi.json');
  if (!specFile.existsSync()) {
    stderr.writeln(
      'openapi/openapi.json is missing. Download it from '
      'https://opencode.ai/v2/openapi.json first.',
    );
    exitCode = 1;
    return;
  }
  final spec = jsonDecode(specFile.readAsStringSync()) as Map<String, dynamic>;
  final generator = _Generator(spec);
  generator.run();
  print(
    'Generated ${generator.declarationCount} declarations and '
    '${generator.resourceCount} resources.',
  );
  final format = await Process.run(Platform.resolvedExecutable, [
    'format',
    'lib/src/generated',
    '--line-length',
    '80',
  ]);
  if (format.exitCode != 0) {
    stderr.write(format.stdout);
    stderr.write(format.stderr);
    exitCode = format.exitCode;
    return;
  }
  print('Formatted generated sources.');
}

// ---------------------------------------------------------------------------
// Naming helpers
// ---------------------------------------------------------------------------

const Set<String> _dartReservedWords = {
  'abstract',
  'as',
  'assert',
  'await',
  'base',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'of',
  'on',
  'operator',
  'part',
  'rethrow',
  'return',
  'sealed',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'while',
  'with',
  'yield',
};

List<String> _segmentsOf(String raw) => raw
    .split(RegExp(r'[^A-Za-z0-9]+'))
    .where((segment) => segment.isNotEmpty)
    .toList();

String pascalCase(String raw) {
  final buffer = StringBuffer();
  for (final segment in _segmentsOf(raw)) {
    buffer.write(segment[0].toUpperCase());
    buffer.write(segment.substring(1));
  }
  final text = buffer.toString();
  if (text.isEmpty) return text;
  if (RegExp(r'^[0-9]').hasMatch(text)) return 'v$text';
  return text;
}

String camelCase(String raw) {
  final pascal = pascalCase(raw);
  if (pascal.isEmpty) return pascal;
  return pascal[0].toLowerCase() + pascal.substring(1);
}

String safeIdentifier(String raw) {
  final candidate = camelCase(raw);
  if (_dartReservedWords.contains(candidate)) {
    return '${candidate}Value';
  }
  return candidate;
}

String escapeString(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'")
    .replaceAll(r'$', r'\$');

// ---------------------------------------------------------------------------
// Type model
// ---------------------------------------------------------------------------

sealed class CType {
  const CType();

  String get dart;

  String fromJson(String expr);

  String toJsonExpr(String expr);

  String dartNullable() => '$dart?';
}

final class CString extends CType {
  const CString();
  @override
  final String dart = 'String';
  @override
  String fromJson(String expr) => 'asJsonString($expr)';
  @override
  String toJsonExpr(String expr) => expr;
}

final class CInt extends CType {
  const CInt();
  @override
  final String dart = 'int';
  @override
  String fromJson(String expr) => 'asJsonInt($expr)';
  @override
  String toJsonExpr(String expr) => expr;
}

final class CDouble extends CType {
  const CDouble();
  @override
  final String dart = 'double';
  @override
  String fromJson(String expr) => 'asJsonDouble($expr)';
  @override
  String toJsonExpr(String expr) => expr;
}

final class CBool extends CType {
  const CBool();
  @override
  final String dart = 'bool';
  @override
  String fromJson(String expr) => 'asJsonBool($expr)';
  @override
  String toJsonExpr(String expr) => expr;
}

final class CDynamic extends CType {
  const CDynamic();
  @override
  String get dart => 'Object?';
  @override
  String dartNullable() => dart;
  @override
  String fromJson(String expr) => expr;
  @override
  String toJsonExpr(String expr) => expr;
}

final class CByteList extends CType {
  const CByteList();
  @override
  final String dart = 'Uint8List';
  @override
  String fromJson(String expr) => 'asJsonList($expr).cast<int>()';
  @override
  String toJsonExpr(String expr) => expr;
}

final class CExtension extends CType {
  const CExtension(this.name, this.repr);

  final String name;
  final String repr;

  @override
  String get dart => name;

  @override
  String fromJson(String expr) {
    if (repr == 'int') return '$name.fromJson(asJsonInt($expr))';
    if (repr == 'double') return '$name.fromJson(asJsonDouble($expr))';
    if (repr == 'bool') return '$name.fromJson(asJsonBool($expr))';
    return '$name.fromJson(asJsonString($expr))';
  }

  @override
  String toJsonExpr(String expr) => expr;
}

final class CEnumType extends CType {
  const CEnumType(this.name);

  final String name;

  @override
  String get dart => name;

  @override
  String fromJson(String expr) => '$name.fromJson($expr)';

  @override
  String toJsonExpr(String expr) => '$expr.wire';
}

final class CObject extends CType {
  const CObject(this.name);

  final String name;

  @override
  String get dart => name;

  @override
  String fromJson(String expr) => '$name.fromJson(asJsonMap($expr))';

  @override
  String toJsonExpr(String expr) => '$expr.toJson()';
}

final class CUnion extends CType {
  const CUnion(this.name);

  final String name;

  @override
  String get dart => name;

  @override
  String fromJson(String expr) => '$name.fromJson(asJsonMap($expr))';

  @override
  String toJsonExpr(String expr) => '$expr.toJson()';
}

final class CListType extends CType {
  const CListType(this.element);

  final CType element;

  @override
  String get dart => 'List<${element.dart}>';

  @override
  String fromJson(String expr) =>
      'jsonList($expr, (item) => ${element.fromJson('item')})';

  @override
  String toJsonExpr(String expr) {
    final isIdentity = element.toJsonExpr('item') == 'item';
    if (isIdentity) return expr;
    return '[for (final item in $expr) ${element.toJsonExpr('item')}]';
  }
}

final class CMapType extends CType {
  const CMapType();

  @override
  final String dart = 'Map<String, Object?>';
  @override
  String fromJson(String expr) => 'asJsonMap($expr)';
  @override
  String toJsonExpr(String expr) => expr;
}

final class CMapOfType extends CType {
  const CMapOfType(this.value);

  final CType value;

  @override
  String get dart => 'Map<String, ${value.dart}>';

  @override
  String fromJson(String expr) =>
      'jsonMap($expr, (item) => ${value.fromJson('item')})';

  @override
  String toJsonExpr(String expr) {
    final isIdentity = value.toJsonExpr('item') == 'item';
    if (isIdentity) return expr;
    return '{for (final entry in $expr.entries) '
        'entry.key: ${value.toJsonExpr('entry.value')}}';
  }
}

final class CConstString extends CType {
  const CConstString(this.value);

  final String value;

  @override
  final String dart = 'String';
  @override
  String fromJson(String expr) => 'asJsonString($expr)';
  @override
  String toJsonExpr(String expr) => "'${escapeString(value)}'";
}

final class CConstBool extends CType {
  const CConstBool(this.value);

  final bool value;

  @override
  final String dart = 'bool';
  @override
  String fromJson(String expr) => 'asJsonBool($expr)';
  @override
  String toJsonExpr(String expr) => '$value';
}

final class CLocationRef extends CType {
  const CLocationRef();
  @override
  final String dart = 'LocationRef';
  @override
  String fromJson(String expr) => 'LocationRef.fromJson($expr)';
  @override
  String toJsonExpr(String expr) => '$expr.toJson()';
}

// ---------------------------------------------------------------------------
// Declaration records
// ---------------------------------------------------------------------------

enum DeclKind {
  object,
  union,
  enumType,
  extensionType,
  alias,
  freemap,
  list,
  dynamicType
}

final class ObjectProperty {
  ObjectProperty({
    required this.jsonName,
    required this.dartName,
    required this.type,
    required this.required,
    required this.isConst,
    required this.schemaNullable,
    this.constValue,
  });

  final String jsonName;
  final String dartName;
  final CType type;
  final bool required;
  final bool isConst;
  final bool schemaNullable;
  final Object? constValue;

  /// Whether the Dart field is nullable.
  bool get nullable => !required || schemaNullable;
}

final class UnionVariant {
  UnionVariant({
    required this.className,
    required this.discriminators,
  });

  final String className;
  final Map<String, Object> discriminators;
}

final class Declaration {
  Declaration({
    required this.schemaName,
    required this.dartName,
    required this.kind,
    this.schema,
    this.properties,
    this.variants,
    this.enumValues,
    this.repr,
    this.alias,
    this.listElement,
    this.mapValue,
    this.bucket,
    this.isError = false,
  });

  final String schemaName;
  final String dartName;
  DeclKind kind;
  Map<String, dynamic>? schema;
  List<ObjectProperty>? properties;
  List<UnionVariant>? variants;
  List<String>? enumValues;
  String? repr;
  CType? alias;
  CType? listElement;
  CType? mapValue;
  final String? bucket;
  final bool isError;
  bool emitted = false;
  String? unionParentName;
}

// ---------------------------------------------------------------------------
// Generator
// ---------------------------------------------------------------------------

class _Generator {
  _Generator(this.spec)
      : schemas = (spec['components'] as Map<String, dynamic>)['schemas']
            as Map<String, dynamic>,
        paths = spec['paths'] as Map<String, dynamic>;

  final Map<String, dynamic> spec;
  final Map<String, dynamic> schemas;
  final Map<String, dynamic> paths;

  final Map<String, Declaration> _bySchema = {};
  final Map<String, Declaration> _byDartName = {};
  final Set<String> _usedNames = {};
  final List<Declaration> _queue = [];
  final Expando<Map<String, CType>> _typeCache =
      Expando<Map<String, CType>>('opencode-type-cache');

  final StringBuffer _primitives = StringBuffer();
  final StringBuffer _enums = StringBuffer();
  final StringBuffer _errors = StringBuffer();
  final Map<String, StringBuffer> _buckets = {};

  final Map<String, String> _resourceFileByTag = {};

  int get declarationCount => _queue.length;
  int get resourceCount => _resourceTags.length;

  static const Map<String, String> _tagAliases = {'filesystem': 'fs'};
  static const Map<String, String> _leafRenames = {
    'import': 'importSession',
    'export': 'exportSession',
  };
  static const Map<String, String> _schemaRenames = {
    // Avoids a clash with the generated `McpResource` API resource class.
    'Mcp.Resource': 'McpResourceInfo',
  };

  List<String> get _resourceTags {
    final tags = <String>[];
    for (final item in paths.values) {
      final entry = item as Map<String, dynamic>;
      for (final method in const ['get', 'post', 'put', 'patch', 'delete']) {
        final operation = entry[method];
        if (operation is! Map<String, dynamic>) continue;
        final tagsOfOperation = (operation['tags'] as List?) ?? const [];
        final tag =
            tagsOfOperation.isEmpty ? 'misc' : '${tagsOfOperation.first}';
        if (!tags.contains(tag)) tags.add(tag);
      }
    }
    tags.sort();
    return tags;
  }

  String _uniqueName(String base) {
    if (base.isEmpty) base = 'Anonymous';
    if (_usedNames.add(base)) return base;
    var index = 2;
    while (!_usedNames.add('$base$index')) {
      index++;
    }
    return '$base$index';
  }

  // -------------------------------------------------------------------------
  // Declarations
  // -------------------------------------------------------------------------

  Declaration _declare(String schemaName) {
    final existing = _bySchema[schemaName];
    if (existing != null) return existing;
    final raw = schemas[schemaName];
    if (raw is! Map<String, dynamic>) {
      throw StateError('Unknown schema: $schemaName');
    }
    final isError = schemaName.endsWith('ErrorEncoded');
    final baseName = isError
        ? schemaName.substring(0, schemaName.length - 'Encoded'.length)
        : schemaName;
    final declaration = Declaration(
      schemaName: schemaName,
      dartName: _uniqueName(
        _schemaRenames[schemaName] ?? pascalCase(baseName),
      ),
      kind: DeclKind.dynamicType,
      schema: raw,
      isError: isError,
      bucket: _bucketFor(schemaName),
    );
    _bySchema[schemaName] = declaration;
    _byDartName[declaration.dartName] = declaration;
    _queue.add(declaration);
    _classify(declaration);
    return declaration;
  }

  static String _bucketFor(String schemaName) {
    if (schemaName.endsWith('ErrorEncoded')) return 'errors';
    switch (schemaName.split('.').first) {
      case 'Session':
      case 'SessionsResponse':
      case 'SessionActive':
      case 'Snapshot':
      case 'TokenUsage':
      case 'SessionStats':
      case 'SessionTransfer':
      case 'SessionsCursor':
      case 'FileDiff':
        return 'session';
      case 'Form':
        return 'form';
      case 'Permission':
      case 'PermissionSaved':
        return 'permission';
      case 'Integration':
      case 'Mcp':
      case 'Credential':
      case 'Connection':
      case 'Plugin':
      case 'Provider':
      case 'Model':
        return 'ecosystem';
      case 'Config':
      case 'ConfigShell':
      case 'ConfigWebSearch':
        return 'config';
      case 'Worktree':
      case 'Vcs':
        return 'vcs';
      case 'Pty':
      case 'PersistentPty':
        return 'pty';
      default:
        return 'core';
    }
  }

  void _classify(Declaration declaration) {
    final schema = declaration.schema!;

    // Verified special cases without a natural Dart representation.
    switch (declaration.schemaName) {
      case 'Location.PublicRef':
        declaration
          ..kind = DeclKind.alias
          ..alias = const CLocationRef();
        return;
      case 'Model.ReasoningField':
        declaration
          ..kind = DeclKind.alias
          ..alias = const CString();
        return;
      case 'Form.Value':
      case 'Session.Inbox.CompactionPayload':
        declaration
          ..kind = DeclKind.alias
          ..alias = const CDynamic();
        return;
    }

    final ref = schema[r'$ref'];
    if (ref is String) {
      declaration.kind = DeclKind.alias;
      declaration.alias = _refType(ref);
      return;
    }

    final anyOf = schema['anyOf'];
    if (anyOf is List) {
      final nonNull = _nonNullVariants(anyOf);
      if (nonNull.length == 1) {
        declaration.kind = DeclKind.alias;
        declaration.alias = _typeOf(nonNull.single, declaration.dartName);
        return;
      }
      final scalar = _scalarUnion(nonNull);
      if (scalar != null) {
        declaration.kind = DeclKind.alias;
        declaration.alias = scalar;
        return;
      }
      if (!_allDiscriminated(nonNull)) {
        declaration.kind = DeclKind.alias;
        declaration.alias = const CDynamic();
        return;
      }
      declaration.kind = DeclKind.union;
      _buildUnion(declaration, nonNull);
      return;
    }

    switch (schema['type']) {
      case 'string':
        final enumValues = (schema['enum'] as List?)?.cast<Object>();
        if (enumValues != null && enumValues.length > 1) {
          declaration.kind = DeclKind.enumType;
          declaration.enumValues = enumValues.map((value) => '$value').toList();
          return;
        }
        if (enumValues != null && enumValues.length == 1) {
          declaration.kind = DeclKind.alias;
          declaration.alias = CConstString('${enumValues.single}');
          return;
        }
        declaration
          ..kind = DeclKind.extensionType
          ..repr = 'String';
        return;
      case 'number':
        declaration
          ..kind = DeclKind.extensionType
          ..repr = 'double';
        return;
      case 'integer':
        declaration
          ..kind = DeclKind.extensionType
          ..repr = 'int';
        return;
      case 'boolean':
        declaration
          ..kind = DeclKind.extensionType
          ..repr = 'bool';
        return;
      case 'object':
        if (schema['patternProperties'] is Map) {
          final pattern = (schema['patternProperties'] as Map).values.first;
          declaration
            ..kind = DeclKind.freemap
            ..mapValue = _typeOf(
              (pattern as Map).cast<String, dynamic>(),
              declaration.dartName,
            );
          return;
        }
        if (schema['properties'] is! Map) {
          declaration.kind = DeclKind.freemap;
          return;
        }
        declaration.kind = DeclKind.object;
        declaration.properties = _buildProperties(
          declaration.dartName,
          schema,
          isError: declaration.isError,
        );
        return;
      case 'array':
        final items = schema['items'];
        declaration.kind = DeclKind.list;
        declaration.listElement = items is Map<String, dynamic>
            ? _typeOf(items, declaration.dartName)
            : const CDynamic();
        return;
      default:
        declaration.kind = DeclKind.dynamicType;
        return;
    }
  }

  List<Map<String, dynamic>> _nonNullVariants(List<dynamic> anyOf) => [
        for (final variant in anyOf)
          if ((variant as Map<String, dynamic>)['type'] != 'null') variant,
      ];

  CType? _scalarUnion(List<Map<String, dynamic>> variants) {
    var sawString = false;
    var sawNumber = false;
    var sawInt = false;
    var sawBool = false;
    for (final variant in variants) {
      if (variant.containsKey(r'$ref')) return null;
      switch (variant['type']) {
        case 'string':
          sawString = true;
        case 'integer':
          sawInt = true;
        case 'number':
          sawNumber = true;
        case 'boolean':
          sawBool = true;
        default:
          return null;
      }
    }
    if (sawBool && !sawString && !sawNumber && !sawInt) return const CBool();
    if (sawString && !sawNumber && !sawInt && !sawBool) return const CString();
    if ((sawNumber || sawInt) && !sawString && !sawBool) {
      return sawNumber ? const CDouble() : const CInt();
    }
    return const CDynamic();
  }

  static bool _schemaNullable(Map<String, dynamic> schema) {
    if (schema['type'] == 'null') return true;
    final anyOf = schema['anyOf'];
    if (anyOf is List) {
      return anyOf.any((variant) => (variant as Map)['type'] == 'null');
    }
    return false;
  }

  List<ObjectProperty> _buildProperties(
    String context,
    Map<String, dynamic> schema, {
    bool isError = false,
  }) {
    final rawProperties = schema['properties'];
    if (rawProperties is! Map) {
      throw StateError(
        'Schema for $context has no properties but was treated as an object',
      );
    }
    final properties = rawProperties.cast<String, dynamic>();
    final required = ((schema['required'] as List?) ?? const [])
        .map((value) => '$value')
        .toSet();
    final result = <ObjectProperty>[];
    final used = <String>{};
    for (final entry in properties.entries) {
      final jsonName = entry.key;
      if (isError && (jsonName == '_tag' || jsonName == 'message')) continue;
      final propertySchema = (entry.value as Map).cast<String, dynamic>();
      var dartName = safeIdentifier(jsonName);
      while (!used.add(dartName)) {
        dartName = '${dartName}2';
      }
      final type = _typeOf(propertySchema, '$context${pascalCase(jsonName)}');
      final isConst = type is CConstString || type is CConstBool;
      result.add(
        ObjectProperty(
          jsonName: jsonName,
          dartName: dartName,
          type: type,
          required: required.contains(jsonName) || isConst,
          isConst: isConst,
          schemaNullable: _schemaNullable(propertySchema),
          constValue: switch (type) {
            CConstString(value: final value) => value,
            CConstBool(value: final value) => value,
            _ => null,
          },
        ),
      );
    }
    return result;
  }

  // -------------------------------------------------------------------------
  // Unions
  // -------------------------------------------------------------------------

  void _buildUnion(
    Declaration declaration,
    List<Map<String, dynamic>> variants,
  ) {
    declaration.variants = _resolveVariants(
      variants,
      declaration.dartName,
      declaration.bucket,
    );
    for (final variant in declaration.variants!) {
      _byDartName[variant.className]?.unionParentName = declaration.dartName;
    }
  }

  List<UnionVariant> _resolveVariants(
    List<Map<String, dynamic>> variants,
    String ownerName,
    String? bucket,
  ) {
    final resolved = <UnionVariant>[];
    for (final variant in variants) {
      final ref = variant[r'$ref'];
      if (ref is String) {
        final name = ref.split('/').last;
        final targetDeclaration = _declare(name);
        final targetSchema = schemas[name] as Map<String, dynamic>;
        final anyOf = targetSchema['anyOf'];
        final discriminators = anyOf is List
            ? _intersectDiscriminators(_nonNullVariants(anyOf))
            : _discriminatorsOf(targetSchema);
        resolved.add(
          UnionVariant(
            className: targetDeclaration.dartName,
            discriminators: discriminators,
          ),
        );
        continue;
      }
      final discriminators = _discriminatorsOf(variant);
      final label = discriminators.values.isEmpty
          ? 'Variant${resolved.length + 1}'
          : pascalCase('${discriminators.values.first}');
      final className = _uniqueName('$ownerName$label');
      final variantDeclaration = Declaration(
        schemaName: className,
        dartName: className,
        kind: DeclKind.object,
        schema: variant,
        bucket: bucket,
      );
      variantDeclaration.properties = _buildProperties(className, variant);
      _byDartName[className] = variantDeclaration;
      _queue.add(variantDeclaration);
      resolved.add(
        UnionVariant(className: className, discriminators: discriminators),
      );
    }
    return resolved;
  }

  Map<String, Object> _intersectDiscriminators(
    List<Map<String, dynamic>> variants,
  ) {
    Map<String, Object>? intersection;
    for (final variant in variants) {
      final ref = variant[r'$ref'];
      final Map<String, dynamic> schema;
      if (ref is String) {
        final target = schemas[ref.split('/').last];
        if (target is! Map<String, dynamic>) return const <String, Object>{};
        final anyOf = target['anyOf'];
        if (anyOf is List) {
          final nested = _intersectDiscriminators(_nonNullVariants(anyOf));
          if (intersection == null) {
            intersection = Map.of(nested);
          } else {
            intersection.removeWhere((key, value) => nested[key] != value);
          }
          continue;
        }
        schema = target;
      } else {
        schema = variant;
      }
      final current = _discriminatorsOf(schema);
      if (intersection == null) {
        intersection = Map.of(current);
      } else {
        intersection.removeWhere((key, value) => current[key] != value);
      }
    }
    return intersection ?? const <String, Object>{};
  }

  /// Whether every variant can participate in a discriminated sealed union.
  bool _allDiscriminated(List<Map<String, dynamic>> variants) {
    for (final variant in variants) {
      final ref = variant[r'$ref'];
      if (ref is String) {
        final target = schemas[ref.split('/').last];
        if (target is! Map<String, dynamic>) return false;
        final anyOf = target['anyOf'];
        if (anyOf is List) {
          final nested = _nonNullVariants(anyOf);
          if (nested.isEmpty) return false;
          if (_intersectDiscriminators(nested).isEmpty) return false;
          if (!_allDiscriminated(nested)) return false;
        } else {
          if (target['properties'] is! Map) return false;
          if (_discriminatorsOf(target).isEmpty) return false;
        }
      } else {
        if (variant['properties'] is! Map) return false;
        if (_discriminatorsOf(variant).isEmpty) return false;
      }
    }
    return true;
  }

  Map<String, Object> _discriminatorsOf(Map<String, dynamic> schema) {
    final properties = schema['properties'];
    if (properties is! Map) return const <String, Object>{};
    final result = <String, Object>{};
    for (final entry in properties.entries) {
      final property = entry.value;
      if (property is! Map) continue;
      final enumValues = property['enum'];
      if (enumValues is List && enumValues.length == 1) {
        final value = enumValues.single;
        if (value is String) {
          result['${entry.key}'] = value;
        } else if (value is bool) {
          result['${entry.key}'] = value;
        }
      }
    }
    return result;
  }

  // -------------------------------------------------------------------------
  // Type resolution
  // -------------------------------------------------------------------------

  CType _refType(String ref) {
    final name = ref.split('/').last;
    if (name == 'Location.PublicRef') return const CLocationRef();
    return _typeOfDeclaration(_declare(name));
  }

  CType _typeOfDeclaration(Declaration declaration) {
    switch (declaration.kind) {
      case DeclKind.alias:
        return declaration.alias ?? const CDynamic();
      case DeclKind.object:
        return CObject(declaration.dartName);
      case DeclKind.union:
        return CUnion(declaration.dartName);
      case DeclKind.enumType:
        return CEnumType(declaration.dartName);
      case DeclKind.extensionType:
        return CExtension(declaration.dartName, declaration.repr ?? 'String');
      case DeclKind.freemap:
        final value = declaration.mapValue;
        return value == null ? const CMapType() : CMapOfType(value);
      case DeclKind.list:
        return CListType(declaration.listElement ?? const CDynamic());
      case DeclKind.dynamicType:
        return const CDynamic();
    }
  }

  CType _typeOf(Map<String, dynamic> schema, String context) {
    // Identity-keyed cache: `Expando` avoids hash-collision hazards that a
    // combined `Object.hash` key would introduce.
    final byContext = _typeCache[schema] ??= <String, CType>{};
    final cached = byContext[context];
    if (cached != null) return cached;
    final result = _resolveTypeOf(schema, context);
    byContext[context] = result;
    return result;
  }

  CType _resolveTypeOf(Map<String, dynamic> schema, String context) {
    final ref = schema[r'$ref'];
    if (ref is String) return _refType(ref);

    final anyOf = schema['anyOf'];
    if (anyOf is List) {
      final nonNull = _nonNullVariants(anyOf);
      if (nonNull.length == 1) return _typeOf(nonNull.single, context);
      final scalar = _scalarUnion(nonNull);
      if (scalar != null) return scalar;
      if (!_allDiscriminated(nonNull)) return const CDynamic();
      return CUnion(_unionOfInline(nonNull, context).dartName);
    }

    switch (schema['type']) {
      case 'string':
        final enumValues = (schema['enum'] as List?)?.cast<Object>();
        if (enumValues != null && enumValues.length > 1) {
          return CEnumType(
            _registerEnum(
              _uniqueName(context),
              enumValues.map((value) => '$value').toList(),
            ),
          );
        }
        if (enumValues != null && enumValues.length == 1) {
          return CConstString('${enumValues.single}');
        }
        return const CString();
      case 'number':
        return const CDouble();
      case 'integer':
        return const CInt();
      case 'boolean':
        final enumValues = schema['enum'];
        if (enumValues is List && enumValues.length == 1) {
          return CConstBool(enumValues.single as bool);
        }
        return const CBool();
      case 'object':
        if (schema['patternProperties'] is Map) {
          final pattern = (schema['patternProperties'] as Map).values.first;
          return CMapOfType(
            _typeOf((pattern as Map).cast<String, dynamic>(), context),
          );
        }
        if (schema['properties'] is! Map) return const CMapType();
        final name = _uniqueName(context);
        final declaration = Declaration(
          schemaName: name,
          dartName: name,
          kind: DeclKind.object,
          schema: schema,
          bucket: 'misc',
        );
        declaration.properties = _buildProperties(name, schema);
        _byDartName[name] = declaration;
        _queue.add(declaration);
        return CObject(name);
      case 'array':
        final items = schema['items'];
        if (items is Map<String, dynamic>) {
          if (items['format'] == 'binary' ||
              items['contentEncoding'] == 'base64') {
            return const CByteList();
          }
          return CListType(_typeOf(items, context));
        }
        return const CListType(CDynamic());
      default:
        if (schema['format'] == 'binary') return const CByteList();
        return const CDynamic();
    }
  }

  Declaration _unionOfInline(
    List<Map<String, dynamic>> variants,
    String context,
  ) {
    final name = _uniqueName(context);
    final declaration = Declaration(
      schemaName: name,
      dartName: name,
      kind: DeclKind.union,
      bucket: 'misc',
    );
    _byDartName[name] = declaration;
    _queue.add(declaration);
    declaration.variants = _resolveVariants(variants, name, 'misc');
    for (final variant in declaration.variants!) {
      _byDartName[variant.className]?.unionParentName = declaration.dartName;
    }
    return declaration;
  }

  String _registerEnum(String name, List<String> values) {
    final declaration = Declaration(
      schemaName: name,
      dartName: name,
      kind: DeclKind.enumType,
      enumValues: values,
      bucket: 'misc',
    );
    _byDartName[name] = declaration;
    _queue.add(declaration);
    return name;
  }

  // -------------------------------------------------------------------------
  // Run
  // -------------------------------------------------------------------------

  void run() {
    for (final name in schemas.keys.toList()) {
      _declare(name);
    }
    // Build every resource tree and plan every operation before emitting
    // models so synthesized types land in the right files.
    final trees = <String, _MethodNode>{};
    for (final tag in _resourceTags) {
      if (tag == 'rpc') continue;
      final tree = _buildTree(tag);
      _planOperations(tag, tree);
      trees[tag] = tree;
    }
    _emitAll();
    _writeModels();
    _writeResources(trees);
    _writeClient();
  }

  void _planOperations(String tag, _MethodNode node) {
    for (final operation in node.operations) {
      operation.plan = _buildPlan(operation, tag);
    }
    for (final child in node.children.values) {
      _planOperations(tag, child);
    }
  }

  void _emitAll() {
    for (final declaration in List.of(_queue)) {
      _emitDeclaration(declaration);
    }
  }

  StringBuffer _sinkFor(Declaration declaration) {
    switch (declaration.kind) {
      case DeclKind.extensionType:
        return _primitives;
      case DeclKind.enumType:
        return _enums;
      default:
        if (declaration.isError || declaration.bucket == 'errors') {
          return _errors;
        }
        return _buckets.putIfAbsent(
          declaration.bucket ?? 'misc',
          StringBuffer.new,
        );
    }
  }

  void _emitDeclaration(Declaration declaration) {
    if (declaration.emitted) return;
    declaration.emitted = true;
    switch (declaration.kind) {
      case DeclKind.extensionType:
        _emitExtensionType(declaration);
      case DeclKind.enumType:
        _emitEnum(declaration);
      case DeclKind.object:
        _emitObject(declaration);
      case DeclKind.union:
        _emitUnion(declaration);
      case DeclKind.alias:
      case DeclKind.freemap:
      case DeclKind.list:
      case DeclKind.dynamicType:
        break;
    }
  }

  void _emitExtensionType(Declaration declaration) {
    final repr = declaration.repr!;
    _primitives
      ..writeln('/// `${declaration.schemaName}`')
      ..writeln(
        'extension type const ${declaration.dartName}'
        '($repr value) implements $repr {',
      )
      ..writeln('  /// Decodes this value.')
      ..writeln(
        '  static ${declaration.dartName} fromJson(Object? json) => '
        '${declaration.dartName}(${_primitiveCast(repr, 'json')});',
      )
      ..writeln('}')
      ..writeln();
  }

  static String _primitiveCast(String repr, String expr) {
    switch (repr) {
      case 'int':
        return 'asJsonInt($expr)';
      case 'double':
        return 'asJsonDouble($expr)';
      case 'bool':
        return 'asJsonBool($expr)';
      default:
        return 'asJsonString($expr)';
    }
  }

  void _emitEnum(Declaration declaration) {
    final values = declaration.enumValues!;
    final members = <String, String>{};
    final used = <String>{};
    for (final value in values) {
      var member = safeIdentifier(value);
      while (!used.add(member)) {
        member = '${member}2';
      }
      members[value] = member;
    }
    _enums.writeln('/// `${declaration.schemaName}`');
    _enums.writeln('enum ${declaration.dartName} {');
    final memberEntries = members.entries.toList();
    for (var index = 0; index < memberEntries.length; index++) {
      final entry = memberEntries[index];
      final terminator = index == memberEntries.length - 1 ? ';' : ',';
      _enums.writeln(
        "  ${entry.value}('${escapeString(entry.key)}')$terminator",
      );
    }
    _enums
      ..writeln()
      ..writeln('  const ${declaration.dartName}(this.wire);')
      ..writeln()
      ..writeln('  /// The wire value.')
      ..writeln('  final String wire;')
      ..writeln()
      ..writeln(
        '  /// Decodes a wire value into an enum member.',
      )
      ..writeln(
        '  static ${declaration.dartName} fromJson(Object? value) => '
        'fromWire(asJsonString(value));',
      )
      ..writeln()
      ..writeln(
        '  /// Decodes a wire value into an enum member.',
      )
      ..writeln(
        '  static ${declaration.dartName} fromWire(String value) => '
        'switch (value) {',
      );
    for (final entry in members.entries) {
      _enums.writeln("        '${escapeString(entry.key)}' => ${entry.value},");
    }
    _enums
      ..writeln('        _ => throw OpenCodeDecodeException(')
      ..writeln(
        "            'Unknown ${declaration.dartName} value: \$value'),",
      )
      ..writeln('      };')
      ..writeln('}')
      ..writeln();
  }

  void _emitObject(Declaration declaration) {
    final sink = _sinkFor(declaration);
    final className = declaration.dartName;
    final properties = declaration.properties ?? const <ObjectProperty>[];
    final isError = declaration.isError || declaration.bucket == 'errors';
    final parent = declaration.unionParentName;

    sink.writeln('/// `${declaration.schemaName}`');
    if (parent != null) {
      sink.writeln('final class $className extends $parent {');
    } else if (isError) {
      sink.writeln('final class $className extends OpenCodeApiException {');
    } else {
      sink.writeln('final class $className {');
    }

    final stored = properties.where((property) => !property.isConst).toList();
    final parameters = <String>[
      for (final property in stored)
        property.required
            ? 'required this.${property.dartName}'
            : 'this.${property.dartName}',
      if (isError) 'required String message',
      if (isError) 'Map<String, Object?>? raw',
    ];
    final isConst = !isError;
    if (parameters.isEmpty) {
      sink.writeln(isConst ? '  const $className();' : '  $className();');
    } else {
      sink.writeln(isConst ? '  const $className({' : '  $className({');
      for (final parameter in parameters) {
        sink.writeln('    $parameter,');
      }
      final superCall = isError
          ? " : super(tag: '${_tagOf(declaration)}', message: message, raw: raw)"
          : '';
      sink.writeln('  })$superCall;');
    }
    sink.writeln();

    sink.writeln(
      '  factory $className.fromJson(Map<String, Object?> json) => '
      '$className(',
    );
    for (final property in stored) {
      sink.writeln(
        '        ${property.dartName}: ${_fieldDecoder(property)},',
      );
    }
    if (isError) {
      sink
        ..writeln("        message: asJsonString(json['message']),")
        ..writeln('        raw: json,');
    }
    sink.writeln('      );');
    sink.writeln();

    final inherited = parent == null
        ? const <String, ObjectProperty>{}
        : _commonProperties(
            _byDartName[parent]?.variants ?? const <UnionVariant>[],
          );

    for (final property in stored) {
      if (property.jsonName != property.dartName) {
        sink.writeln('  /// Wire field: `${property.jsonName}`.');
      }
      final type =
          property.nullable ? property.type.dartNullable() : property.type.dart;
      if (inherited.containsKey(property.jsonName)) {
        sink.writeln('  @override');
      }
      sink.writeln('  final $type ${property.dartName};');
    }
    if (stored.isNotEmpty) sink.writeln();

    for (final property in properties.where((property) => property.isConst)) {
      final isBool = property.type is CConstBool;
      final literal = isBool
          ? '${property.constValue}'
          : "'${escapeString('${property.constValue}')}'";
      sink.writeln('  /// Always `${property.constValue}`.');
      if (inherited.containsKey(property.jsonName)) {
        sink.writeln('  @override');
      }
      sink
        ..writeln(
          '  ${isBool ? 'bool' : 'String'} get ${property.dartName} => '
          '$literal;',
        )
        ..writeln();
    }

    if (parent != null) {
      sink.writeln('  @override');
    }
    sink.writeln('  Map<String, Object?> toJson() => <String, Object?>{');
    for (final property in properties) {
      if (property.isConst) {
        final isBool = property.type is CConstBool;
        final literal = isBool
            ? '${property.constValue}'
            : "'${escapeString('${property.constValue}')}'";
        sink.writeln("    '${escapeString(property.jsonName)}': $literal,");
      } else if (property.nullable) {
        sink.writeln(
          '    if (${property.dartName} != null) '
          "'${escapeString(property.jsonName)}': "
          '${property.type.toJsonExpr('${property.dartName}!')},',
        );
      } else {
        sink.writeln(
          "    '${escapeString(property.jsonName)}': "
          '${property.type.toJsonExpr(property.dartName)},',
        );
      }
    }
    sink
      ..writeln('  };')
      ..writeln('}')
      ..writeln();
  }

  String _tagOf(Declaration declaration) {
    final schema = declaration.schema;
    if (schema != null) {
      final properties = schema['properties'];
      if (properties is Map) {
        final tag = properties['_tag'];
        if (tag is Map) {
          final values = tag['enum'];
          if (values is List && values.isNotEmpty) return '${values.first}';
        }
      }
    }
    return declaration.schemaName.replaceAll('Encoded', '');
  }

  /// Decodes one object property, threading the JSON key into decode errors.
  String _fieldDecoder(ObjectProperty property) {
    final key = "'${escapeString(property.jsonName)}'";
    final raw = 'json[$key]';
    if (!property.nullable) {
      return switch (property.type) {
        CString() => 'decodeString(json, $key)',
        CInt() => 'decodeInt(json, $key)',
        CDouble() => 'decodeNumber(json, $key)',
        CBool() => 'decodeBool(json, $key)',
        CDynamic() => raw,
        _ => property.type.fromJson(raw),
      };
    }
    return switch (property.type) {
      CString() => 'decodeOptionalString(json, $key)',
      CInt() => 'decodeOptionalInt(json, $key)',
      CDouble() => 'decodeOptionalNumber(json, $key)',
      CBool() => 'decodeOptionalBool(json, $key)',
      CDynamic() => raw,
      _ => '$raw == null ? null : ${property.type.fromJson(raw)}',
    };
  }

  void _emitUnion(Declaration declaration) {
    final sink = _sinkFor(declaration);
    final className = declaration.dartName;
    final variants = declaration.variants ?? const <UnionVariant>[];
    final discriminator = _pickDiscriminator(variants);
    if (discriminator == null) {
      throw StateError(
        'Union ${declaration.schemaName} has no unambiguous discriminator',
      );
    }
    sink
      ..writeln('/// `${declaration.schemaName}`')
      ..writeln(
        declaration.unionParentName == null
            ? 'sealed class $className {'
            : 'sealed class $className extends ${declaration.unionParentName} {',
      )
      ..writeln('  const $className();')
      ..writeln()
      ..writeln('  /// Decodes a payload into the matching variant.')
      ..writeln('  factory $className.fromJson(Map<String, Object?> json) {')
      ..writeln("    final value = json['${escapeString(discriminator)}'];")
      ..writeln('    return switch (value) {');
    for (final variant in variants) {
      final value = variant.discriminators[discriminator];
      sink.writeln(
        "      '${escapeString('$value')}' => "
        '${variant.className}.fromJson(json),',
      );
    }
    sink
      ..writeln('      _ => throw OpenCodeDecodeException(')
      ..writeln(
        "          'Unknown ${declaration.schemaName} "
        "discriminator: \$value'),",
      )
      ..writeln('    };')
      ..writeln('  }')
      ..writeln();
    // Shared members: properties present on every variant with the same type.
    final parentUnion = declaration.unionParentName == null
        ? null
        : _byDartName[declaration.unionParentName!];
    final parentCommon = parentUnion == null
        ? const <String, ObjectProperty>{}
        : _commonProperties(parentUnion.variants ?? const <UnionVariant>[]);
    for (final entry in _commonProperties(variants).entries) {
      final property = entry.value;
      final type =
          property.nullable ? property.type.dartNullable() : property.type.dart;
      sink.writeln('  /// Present on every variant (`${property.jsonName}`).');
      if (parentCommon.containsKey(property.jsonName)) {
        sink.writeln('  @override');
      }
      sink
        ..writeln('  $type get ${property.dartName};')
        ..writeln();
    }
    sink.writeln('  /// Encodes this value to JSON.');
    if (declaration.unionParentName != null) {
      sink.writeln('  @override');
    }
    sink
      ..writeln('  Map<String, Object?> toJson();')
      ..writeln('}')
      ..writeln();
  }

  /// Properties shared by every variant with an identical Dart type.
  Map<String, ObjectProperty> _commonProperties(
    List<UnionVariant> variants,
  ) {
    if (variants.isEmpty) return const <String, ObjectProperty>{};
    final candidates = Map<String, ObjectProperty>.of(
      _variantProperties(variants.first.className),
    );
    for (final variant in variants.skip(1)) {
      final byName = _variantProperties(variant.className);
      candidates.removeWhere((jsonName, candidate) {
        final other = byName[jsonName];
        if (other == null) return true;
        if (other.nullable != candidate.nullable) return true;
        return other.type.dart != candidate.type.dart;
      });
    }
    candidates.removeWhere((jsonName, _) => jsonName == '_tag');
    return candidates;
  }

  /// The Dart-visible properties of one union variant. Nested unions expose
  /// the members they share across their own variants.
  Map<String, ObjectProperty> _variantProperties(String className) {
    final declaration = _byDartName[className];
    if (declaration == null) return const <String, ObjectProperty>{};
    if (declaration.kind == DeclKind.union) {
      return _commonProperties(declaration.variants ?? const []);
    }
    return <String, ObjectProperty>{
      for (final property in declaration.properties ?? const <ObjectProperty>[])
        property.jsonName: property,
    };
  }

  String? _pickDiscriminator(List<UnionVariant> variants) {
    if (variants.isEmpty) return null;
    final values = <String, Set<Object?>>{};
    for (final variant in variants) {
      for (final entry in variant.discriminators.entries) {
        values.putIfAbsent(entry.key, () => <Object?>{}).add(entry.value);
      }
    }
    final candidates = values.entries
        .where((entry) => entry.value.length == variants.length)
        .map((entry) => entry.key)
        .toList();
    if (candidates.isEmpty) return null;
    for (final preferred in const ['type', 'status', 'mode']) {
      if (candidates.contains(preferred)) return preferred;
    }
    candidates.sort();
    return candidates.first;
  }

  // -------------------------------------------------------------------------
  // Models library
  // -------------------------------------------------------------------------

  static const List<String> _bucketOrder = [
    'core',
    'session',
    'ecosystem',
    'config',
    'form',
    'permission',
    'vcs',
    'pty',
    'misc',
  ];

  void _writeModels() {
    Directory('lib/src/generated/models').createSync(recursive: true);

    final models = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// Generated by tool/generate.dart from openapi/openapi.json.')
      ..writeln('// ignore_for_file: prefer_single_quotes')
      ..writeln()
      ..writeln('/// Typed models for the OpenCode V2 HTTP API.')
      ..writeln('library;')
      ..writeln()
      ..writeln("import '../core/errors.dart';")
      ..writeln("import '../core/json_utils.dart';")
      ..writeln("import '../core/request_options.dart';")
      ..writeln()
      ..writeln("part 'models/primitives.dart';")
      ..writeln("part 'models/enums.dart';")
      ..writeln("part 'models/helpers.dart';");
    for (final bucket in _bucketOrder) {
      models.writeln("part 'models/$bucket.dart';");
    }
    models.writeln("part 'models/errors.dart';");
    models
      ..writeln()
      ..writeln('/// A response envelope carrying a location and a payload.')
      ..writeln('final class LocatedResponse<T> {')
      ..writeln(
        '  const LocatedResponse({required this.location, required this.data});',
      )
      ..writeln()
      ..writeln('  /// Decodes a `{location, data}` response envelope.')
      ..writeln(
        '  static LocatedResponse<T> fromJson<T>('
        'Map<String, Object?> json, T Function(Object? value) decode) =>',
      )
      ..writeln('        LocatedResponse<T>(')
      ..writeln("          location: LocationRef.fromJson(json['location']),")
      ..writeln("          data: decode(json['data']),")
      ..writeln('        );')
      ..writeln()
      ..writeln('  /// The location this response belongs to.')
      ..writeln('  final LocationRef location;')
      ..writeln()
      ..writeln('  /// The payload.')
      ..writeln('  final T data;')
      ..writeln('}');

    File('lib/src/generated/models.dart').writeAsStringSync(models.toString());
    File('lib/src/generated/models/primitives.dart')
        .writeAsStringSync(_partHeader() + _primitives.toString());
    File('lib/src/generated/models/enums.dart')
        .writeAsStringSync(_partHeader() + _enums.toString());
    File('lib/src/generated/models/helpers.dart').writeAsStringSync(
      '${_partHeader()}'
      '/// Decodes a JSON array with [convert].\n'
      'List<T> jsonList<T>(Object? value, T Function(Object? item) convert) =>\n'
      '    [for (final item in asJsonList(value)) convert(item)];\n'
      '\n'
      '/// Decodes a JSON object into a typed map with [convert].\n'
      'Map<String, T> jsonMap<T>(Object? value, T Function(Object? item) convert) =>\n'
      '    {for (final entry in asJsonMap(value).entries) entry.key: convert(entry.value)};\n',
    );
    for (final bucket in _bucketOrder) {
      File('lib/src/generated/models/$bucket.dart').writeAsStringSync(
        '${_partHeader()}${_buckets[bucket] ?? ''}',
      );
    }
    File('lib/src/generated/models/errors.dart').writeAsStringSync(
      '${_partHeader()}${_errors.toString()}${_exceptionDecoder()}',
    );
  }

  String _partHeader() => '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
      "part of '../models.dart';\n"
      '// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, '
      'use_super_parameters\n'
      '\n';

  String _exceptionDecoder() {
    final buffer = StringBuffer()
      ..writeln('/// Decodes a structured API error from a response body.')
      ..writeln('///')
      ..writeln(
          '/// Returns `null` when the body does not carry a known error.')
      ..writeln(
        'OpenCodeApiException? decodeOpenCodeException('
        'int statusCode, Object? body) {',
      )
      ..writeln('  if (body is! Map) return null;')
      ..writeln('  final json = asJsonMap(body);')
      ..writeln("  final tag = json['_tag'];")
      ..writeln('  if (tag is! String) return null;')
      ..writeln('  return switch (tag) {');
    for (final declaration in _queue) {
      if (!declaration.isError) continue;
      buffer.writeln(
        "    '${escapeString(_tagOf(declaration))}' => "
        '${declaration.dartName}.fromJson(json),',
      );
    }
    buffer
      ..writeln('    _ => null,')
      ..writeln('  };')
      ..writeln('}');
    return buffer.toString();
  }

  // -------------------------------------------------------------------------
  // Resources
  // -------------------------------------------------------------------------

  void _writeResources(Map<String, _MethodNode> trees) {
    Directory('lib/src/generated/resources').createSync(recursive: true);
    for (final tag in _resourceTags) {
      if (tag == 'rpc') continue;
      final fileName = '${_snakeCase(tag)}_resource.dart';
      _resourceFileByTag[tag] = fileName;
      File('lib/src/generated/resources/$fileName')
          .writeAsStringSync(_emitResource(tag, trees[tag]!));
    }
  }

  static String _snakeCase(String value) {
    final buffer = StringBuffer();
    for (var index = 0; index < value.length; index++) {
      final char = value[index];
      final lower = char.toLowerCase();
      if (char != lower &&
          index > 0 &&
          value[index - 1] != value[index - 1].toUpperCase()) {
        buffer.write('_');
      }
      buffer.write(lower);
    }
    return buffer.toString();
  }

  List<_Operation> _operationsOf(String tag) {
    final result = <_Operation>[];
    paths.forEach((path, item) {
      final entry = item as Map<String, dynamic>;
      for (final method in const ['get', 'post', 'put', 'patch', 'delete']) {
        final operation = entry[method];
        if (operation is! Map<String, dynamic>) continue;
        final tags = (operation['tags'] as List?) ?? const [];
        final tagOfOperation = tags.isEmpty ? 'misc' : '${tags.first}';
        if (tagOfOperation != tag) continue;
        result.add(
          _Operation(
            method: method.toUpperCase(),
            path: path,
            operationId: operation['operationId'] as String,
            operation: operation,
          ),
        );
      }
    });
    return result;
  }

  _MethodNode _buildTree(String tag) {
    final root = _MethodNode(name: tag, className: pascalCase(tag));
    for (final operation in _operationsOf(tag)) {
      final segments = _methodSegments(tag, operation.operationId);
      var node = root;
      for (final segment in segments.take(segments.length - 1)) {
        node = node.children.putIfAbsent(
          segment,
          () => _MethodNode(
            name: segment,
            className: '${node.className}${pascalCase(segment)}',
          ),
        );
      }
      node.operations.add(operation..methodName = segments.last);
    }
    _flattenSingleChildGroups(root);
    return root;
  }

  void _flattenSingleChildGroups(_MethodNode node) {
    for (final entry in node.children.entries.toList()) {
      final child = entry.value;
      if (child.children.isEmpty && child.operations.isNotEmpty) {
        final collides = node.operations.any(
          (operation) => operation.methodName == child.name,
        );
        if (child.operations.length == 1 || collides) {
          final merged = <_Operation>[];
          var conflict = false;
          for (final operation in child.operations) {
            final renamed = '${child.name}${pascalCase(operation.methodName!)}';
            if (node.operations.any(
                  (candidate) => candidate.methodName == renamed,
                ) ||
                merged.any((candidate) => candidate.methodName == renamed)) {
              conflict = true;
              break;
            }
            merged.add(operation..methodName = renamed);
          }
          if (!conflict) {
            node.operations.addAll(merged);
            node.children.remove(entry.key);
            continue;
          }
        }
      }
      _flattenSingleChildGroups(child);
    }
  }

  List<String> _methodSegments(String tag, String operationId) {
    var segments = operationId.split('.');
    while (segments.length > 1 &&
        (segments.first == 'server' || segments.first == 'experimental')) {
      segments = segments.sublist(1);
    }
    final alias = _tagAliases[tag];
    if (segments.length > 1 &&
        (segments.first == tag || segments.first == alias)) {
      segments = segments.sublist(1);
    }
    final tagIndex = segments.indexOf(tag);
    if (tagIndex > 0 && segments.length > tagIndex + 1) {
      segments = segments.sublist(tagIndex + 1);
    }
    if (segments.length > 1) {
      return [
        for (var index = 0; index < segments.length; index++)
          index == segments.length - 1
              ? _leafName(segments[index])
              : camelCase(segments[index]),
      ];
    }
    return [_leafName(segments.single)];
  }

  static String _leafName(String raw) =>
      safeIdentifier(_leafRenames[raw] ?? raw);

  String _emitResource(String tag, _MethodNode tree) {
    final file = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// Generated by tool/generate.dart from openapi/openapi.json.')
      ..writeln(
        '// ignore_for_file: unnecessary_lambdas, unused_import, '
        'prefer_if_null_operators, prefer_single_quotes, '
        'use_super_parameters',
      )
      ..writeln()
      ..writeln('library;')
      ..writeln()
      ..writeln("import 'dart:typed_data';")
      ..writeln()
      ..writeln("import '../../core/errors.dart';")
      ..writeln("import '../../core/events.dart';")
      ..writeln("import '../../core/json_utils.dart';")
      ..writeln("import '../../core/query.dart';")
      ..writeln("import '../../core/request_options.dart';")
      ..writeln("import '../../core/sse.dart';")
      ..writeln("import '../../core/transport.dart';")
      ..writeln("import '../models.dart';")
      ..writeln();
    _emitNode(file, tree, isRoot: true, tag: tag);
    return file.toString();
  }

  void _emitNode(
    StringBuffer file,
    _MethodNode node, {
    required bool isRoot,
    required String tag,
  }) {
    final className = '${node.className}Resource';
    final needsEvents = isRoot && tag == 'event';
    file
      ..writeln('/// API resource `${node.name}`.')
      ..writeln('final class $className {')
      ..writeln('  /// Creates the resource.')
      ..writeln(
        '  $className(this.transport${needsEvents ? ', this.events' : ''});',
      )
      ..writeln()
      ..writeln('  /// The shared HTTP transport.')
      ..writeln('  final OpenCodeTransport transport;');
    if (needsEvents) {
      file
        ..writeln()
        ..writeln('  /// The shared event multiplexer.')
        ..writeln('  final EventMultiplexer events;');
    }
    file.writeln();

    for (final child in node.children.values) {
      file
        ..writeln('  /// The `${child.name}` group.')
        ..writeln(
          '  late final ${child.className}Resource ${camelCase(child.name)} =',
        )
        ..writeln('      ${child.className}Resource(transport);')
        ..writeln();
    }

    for (final operation in node.operations) {
      _emitOperation(file, operation, tag);
    }

    file
      ..writeln('}')
      ..writeln();

    for (final child in node.children.values) {
      _emitNode(file, child, isRoot: false, tag: tag);
    }
  }

  void _emitOperation(
    StringBuffer file,
    _Operation operation,
    String tag,
  ) {
    final plan = operation.plan ?? _buildPlan(operation, tag);
    if (plan == null) return;
    file
      ..writeln('  /// ${_docText(operation)}')
      ..writeln('  ${plan.signature}${plan.isAsync ? ' async' : ''} {')
      ..writeln(_indent(plan.body, 4))
      ..writeln('  }')
      ..writeln();
  }

  static String _docText(_Operation operation) {
    final summary = operation.operation['summary'];
    final description = operation.operation['description'];
    final parts = <String>[
      if (summary is String && summary.isNotEmpty) summary,
      if (description is String && description.isNotEmpty) description,
    ];
    final text = parts.isEmpty ? operation.operationId : parts.join(' - ');
    return text.replaceAll('\n', ' ').replaceAll('///', '--').trim();
  }

  // -------------------------------------------------------------------------
  // Operation planning
  // -------------------------------------------------------------------------

  _OperationPlan? _buildPlan(_Operation operation, String tag) {
    final parameters = <_Parameter>[];
    final queryParameters = <_Parameter>[];
    final headerParameters = <_Parameter>[];
    var hasLocation = false;

    final rawParameters = <dynamic>[
      ...((operation.operation['parameters'] as List?) ?? const []),
    ];
    for (final parameter in rawParameters) {
      if (parameter is! Map) continue;
      final map = parameter.cast<String, dynamic>();
      final name = '${map['name']}';
      final location = '${map['in']}';
      final required = map['required'] == true;
      final schema = (map['schema'] as Map).cast<String, dynamic>();
      final context = '${operation.methodId}${pascalCase(name)}';
      switch (location) {
        case 'path':
          parameters.add(
            _Parameter(
              name: name,
              dartName: safeIdentifier(name),
              type: _typeOf(schema, context),
              required: true,
            ),
          );
        case 'header':
          headerParameters.add(
            _Parameter(
              name: name,
              dartName: safeIdentifier(name),
              type: const CString(),
              required: false,
            ),
          );
        case 'query':
          if (name == 'location') {
            hasLocation = true;
            continue;
          }
          final anyOf = schema['anyOf'];
          final effective = anyOf is List && _nonNullVariants(anyOf).length == 1
              ? _nonNullVariants(anyOf).single
              : schema;
          queryParameters.add(
            _Parameter(
              name: name,
              dartName: safeIdentifier(name),
              type: _typeOf(effective, context),
              required: required,
            ),
          );
      }
    }

    final wildcard = operation.path.endsWith('/*');
    final body = _bodyParameter(operation);

    final response = _responseOf(operation);
    if (response == null) return null;

    final arguments = <String>[];
    final usedNames = <String>{};
    void addArgument(String name, String signature) {
      if (!usedNames.add(name)) {
        throw StateError(
          'Argument collision for $name in ${operation.operationId}',
        );
      }
      arguments.add(signature);
    }

    for (final parameter in parameters) {
      addArgument(
        parameter.dartName,
        'required ${parameter.type.dart} ${parameter.dartName}',
      );
    }
    if (wildcard) {
      addArgument('path', 'required String path');
    }
    if (hasLocation) {
      addArgument('location', 'LocationRef? location');
    }
    for (final parameter in queryParameters) {
      addArgument(
        parameter.dartName,
        '${parameter.type.dartNullable()} ${parameter.dartName}',
      );
    }
    for (final parameter in headerParameters) {
      addArgument(parameter.dartName, 'String? ${parameter.dartName}');
    }
    if (body != null) {
      for (final field in body.fields) {
        if (field.isConst) continue;
        addArgument(
          field.dartName,
          field.nullable
              ? '${field.type.dartNullable()} ${field.dartName}'
              : 'required ${field.type.dart} ${field.dartName}',
        );
      }
      for (final entry in body.rawArguments.entries) {
        addArgument(entry.key, entry.value);
      }
    }
    addArgument('options', 'RequestOptions? options');

    final signature =
        '${response.returnType} ${operation.methodName}({${arguments.join(', ')}})';

    final bodyText = _buildBody(
      operation: operation,
      response: response,
      queryParameters: queryParameters,
      headerParameters: headerParameters,
      hasLocation: hasLocation,
      wildcard: wildcard,
      body: body,
      needsEvents: tag == 'event',
    );
    final isAsync = switch (response.kind) {
      _ResponseKind.sseEvents || _ResponseKind.sseJson => false,
      _ => true,
    };
    return _OperationPlan(
      signature: signature,
      body: bodyText,
      isAsync: isAsync,
    );
  }

  _BodyParameter? _bodyParameter(_Operation operation) {
    final requestBody = operation.operation['requestBody'];
    if (requestBody is! Map) return null;
    final content = (requestBody['content'] as Map?) ?? const {};
    if (content['application/octet-stream'] != null) {
      return _BodyParameter(
        kind: _BodyKind.binary,
        fields: const [],
        rawArguments: const {
          'payload': 'required List<int> payload',
          'contentType': 'String? contentType',
        },
      );
    }
    final json = content['application/json'];
    if (json is! Map) return null;
    var schema = (json['schema'] as Map).cast<String, dynamic>();

    final ref = schema[r'$ref'];
    if (ref is String) {
      final target = schemas[ref.split('/').last];
      if (target is Map<String, dynamic>) schema = target;
    }
    if (schema['properties'] is! Map) {
      return _BodyParameter(
        kind: _BodyKind.raw,
        fields: const [],
        rawArguments: const {'payload': 'Object? payload'},
      );
    }
    final fields = _buildProperties(
      '${operation.methodId}Input',
      schema,
    );
    return _BodyParameter(kind: _BodyKind.object, fields: fields);
  }

  _ResponseSpec? _responseOf(_Operation operation) {
    final responses = operation.operation['responses'] as Map<String, dynamic>;
    final has200 = responses['200'] != null;
    final success = responses['200'] ?? responses['204'];
    if (success is! Map) return null;
    final status = has200 ? 200 : 204;
    final content = (success['content'] as Map?) ?? const {};

    if (content['text/event-stream'] != null) {
      if (operation.operationId == 'event.subscribe') {
        return const _ResponseSpec(
          returnType: 'Stream<OpenCodeEvent>',
          kind: _ResponseKind.sseEvents,
        );
      }
      return const _ResponseSpec(
        returnType: 'Stream<Map<String, Object?>>',
        kind: _ResponseKind.sseJson,
      );
    }
    if (content['application/octet-stream'] != null) {
      return const _ResponseSpec(
        returnType: 'Future<Uint8List>',
        kind: _ResponseKind.binary,
      );
    }
    final json = content['application/json'];
    if (json is! Map) {
      return _ResponseSpec(
        returnType: 'Future<void>',
        kind: _ResponseKind.empty,
        status: status,
      );
    }
    final schema = (json['schema'] as Map).cast<String, dynamic>();
    if (schema['type'] == 'null') {
      return _ResponseSpec(
        returnType: 'Future<void>',
        kind: _ResponseKind.empty,
        status: status,
      );
    }

    final anyOf = schema['anyOf'];
    if (anyOf is List) {
      final nonNull = _nonNullVariants(anyOf);
      if (nonNull.length == 1) {
        final type = _typeOf(
          nonNull.single,
          '${operation.methodId}Response',
        );
        return _ResponseSpec(
          returnType: 'Future<${type.dartNullable()}>',
          kind: _ResponseKind.nullableValue,
          decodeType: type,
        );
      }
    }

    final ref = schema[r'$ref'];
    if (ref is String) {
      final type = _refType(ref);
      return _ResponseSpec(
        returnType: 'Future<${type.dart}>',
        kind: _ResponseKind.direct,
        decodeType: type,
      );
    }

    switch (schema['type']) {
      case 'array':
        final element = _typeOf(
          (schema['items'] as Map).cast<String, dynamic>(),
          '${operation.methodId}Response',
        );
        final type = CListType(element);
        return _ResponseSpec(
          returnType: 'Future<${type.dart}>',
          kind: _ResponseKind.direct,
          decodeType: type,
        );
      case 'boolean':
        return const _ResponseSpec(
          returnType: 'Future<bool>',
          kind: _ResponseKind.direct,
          decodeType: CBool(),
        );
      case 'object':
        final properties = ((schema['properties'] as Map?) ?? const {})
            .cast<String, dynamic>();
        if (properties.containsKey('data') &&
            properties.containsKey('location')) {
          final data = _typeOf(
            properties['data'] as Map<String, dynamic>,
            '${operation.methodId}Response',
          );
          return _ResponseSpec(
            returnType: 'Future<LocatedResponse<${data.dart}>>',
            kind: _ResponseKind.located,
            decodeType: data,
          );
        }
        if (properties.containsKey('data')) {
          final data = _typeOf(
            properties['data'] as Map<String, dynamic>,
            '${operation.methodId}Response',
          );
          return _ResponseSpec(
            returnType: 'Future<${data.dart}>',
            kind: _ResponseKind.data,
            decodeType: data,
          );
        }
    }

    final type = _typeOf(schema, '${operation.methodId}Response');
    return _ResponseSpec(
      returnType: 'Future<${type.dart}>',
      kind: _ResponseKind.direct,
      decodeType: type,
    );
  }

  String _buildBody({
    required _Operation operation,
    required _ResponseSpec response,
    required List<_Parameter> queryParameters,
    required List<_Parameter> headerParameters,
    required bool hasLocation,
    required bool wildcard,
    required _BodyParameter? body,
    required bool needsEvents,
  }) {
    final buffer = StringBuffer();
    final pathExpression = _pathExpression(operation);

    final queryEntries = <String>[
      if (hasLocation) '...locationQuery(location, options)',
      for (final parameter in queryParameters)
        'if (${parameter.dartName} != null) '
            "'${escapeString(parameter.name)}': "
            '${parameter.type.toJsonExpr(parameter.dartName)}',
    ];
    final queryText = queryEntries.isEmpty
        ? 'null'
        : '<String, Object?>{\n${_indent(queryEntries.join(',\n'), 6)}\n    }';

    final headerEntries = <String>[
      for (final parameter in headerParameters)
        'if (${parameter.dartName} != null) '
            "'${escapeString(parameter.name)}': ${parameter.dartName}",
      if (body?.kind == _BodyKind.binary)
        "'content-type': contentType ?? 'application/octet-stream'",
    ];
    final headerText = headerEntries.isEmpty
        ? null
        : '<String, String>{\n${_indent(headerEntries.join(',\n'), 6)}\n    }';

    if (response.kind == _ResponseKind.sseEvents && needsEvents) {
      buffer.writeln('return events.subscribe();');
      return buffer.toString();
    }

    if (response.kind == _ResponseKind.sseJson) {
      buffer
        ..writeln('final frames = transport.sseFrames(')
        ..writeln('  path: $pathExpression,')
        ..writeln('  query: $queryText,')
        ..writeln(
          headerText == null ? '  headers: null,' : '  headers: $headerText,',
        )
        ..writeln('  options: options,')
        ..writeln(');')
        ..writeln('return frames.map((frame) {')
        ..writeln('  final value = unwrapEmbeddedJson(frame);')
        ..writeln('  return value is Map')
        ..writeln('      ? asJsonMap(value)')
        ..writeln("      : <String, Object?>{'value': value};")
        ..writeln('});');
      return buffer.toString();
    }

    final callArguments = <String>[
      "method: '${operation.method}',",
      'path: $pathExpression,',
      if (queryText != 'null') 'query: $queryText,',
      if (headerText != null) 'headers: $headerText,',
      if (body != null)
        switch (body.kind) {
          _BodyKind.binary => 'body: payload,',
          _BodyKind.raw => 'body: payload,',
          _BodyKind.object => 'body: ${_bodyJson(body)},',
        },
      if (body?.kind == _BodyKind.binary) 'binaryBody: true,',
      if (response.kind == _ResponseKind.empty) 'empty: true,',
      if (response.status != 200) 'successStatus: ${response.status},',
      'options: options,',
    ];

    final transportCall = response.kind == _ResponseKind.binary
        ? 'transport.bytesRequest'
        : 'transport.jsonRequest';
    if (response.kind == _ResponseKind.empty) {
      buffer
        ..writeln('await $transportCall(')
        ..writeln(_indent(callArguments.join('\n'), 6))
        ..writeln(');');
    } else {
      buffer
        ..writeln('final result = await $transportCall(')
        ..writeln(_indent(callArguments.join('\n'), 6))
        ..writeln(');');
    }

    switch (response.kind) {
      case _ResponseKind.empty:
        break;
      case _ResponseKind.binary:
        buffer.writeln('return result;');
      case _ResponseKind.direct:
        buffer.writeln(
          'return ${response.decodeType!.fromJson('result')};',
        );
      case _ResponseKind.data:
        buffer.writeln(
          "return ${response.decodeType!.fromJson("asJsonMap(result)['data']")};",
        );
      case _ResponseKind.located:
        buffer.writeln(
          'return LocatedResponse.fromJson(asJsonMap(result), '
          '(value) => ${response.decodeType!.fromJson('value')});',
        );
      case _ResponseKind.nullableValue:
        buffer.writeln(
          'return result == null ? null : '
          '${response.decodeType!.fromJson('result')};',
        );
      case _ResponseKind.sseEvents:
      case _ResponseKind.sseJson:
        break;
    }
    return buffer.toString();
  }

  String _pathExpression(_Operation operation) {
    var path = operation.path;
    final wildcard = path.endsWith('/*');
    if (wildcard) path = path.substring(0, path.length - 2);
    final buffer = StringBuffer("'");
    for (final part in path.split('/')) {
      if (part.isEmpty) continue;
      buffer.write('/');
      if (part.startsWith('{') && part.endsWith('}')) {
        final name = safeIdentifier(part.substring(1, part.length - 1));
        buffer.write('\${Uri.encodeComponent($name.toString())}');
      } else {
        buffer.write(part);
      }
    }
    if (wildcard) {
      buffer.write("/\${path.split('/').map(Uri.encodeComponent).join('/')}");
    }
    buffer.write("'");
    return buffer.toString();
  }

  String _bodyJson(_BodyParameter body) {
    final entries = <String>[
      for (final field in body.fields)
        if (field.isConst)
          "'${escapeString(field.jsonName)}': "
              '${field.type.toJsonExpr('null')}'
        else if (field.nullable)
          'if (${field.dartName} != null) '
              "'${escapeString(field.jsonName)}': "
              '${field.type.toJsonExpr(field.dartName)}'
        else
          "'${escapeString(field.jsonName)}': "
              '${field.type.toJsonExpr(field.dartName)}',
    ];
    if (entries.isEmpty) return '<String, Object?>{}';
    return '<String, Object?>{\n${_indent(entries.join(',\n'), 6)}\n    }';
  }

  static String _indent(String text, int spaces) {
    final prefix = ' ' * spaces;
    return text
        .split('\n')
        .map((line) => line.isEmpty ? line : '$prefix$line')
        .join('\n');
  }

  // -------------------------------------------------------------------------
  // Client
  // -------------------------------------------------------------------------

  void _writeClient() {
    final file = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// Generated by tool/generate.dart from openapi/openapi.json.')
      ..writeln(
        '// ignore_for_file: unnecessary_lambdas, unused_import, '
        'prefer_if_null_operators, prefer_single_quotes, '
        'use_super_parameters',
      )
      ..writeln()
      ..writeln('/// The assembled OpenCode client.')
      ..writeln('library;')
      ..writeln()
      ..writeln("import 'package:http/http.dart' as http;")
      ..writeln()
      ..writeln("import '../core/events.dart';")
      ..writeln("import '../core/json_utils.dart';")
      ..writeln("import '../core/request_options.dart';")
      ..writeln("import '../core/transport.dart';")
      ..writeln("import '../rpc/rpc.dart';")
      ..writeln("import '../service/service.dart';")
      ..writeln("import 'models.dart';");
    for (final tag in _resourceTags) {
      if (tag == 'rpc') continue;
      file.writeln("import 'resources/${_resourceFileByTag[tag]}';");
    }
    file
      ..writeln()
      ..writeln('/// Typed client for one OpenCode server.')
      ..writeln('///')
      ..writeln('/// ```dart')
      ..writeln('/// final client = OpenCodeClient.make(')
      ..writeln("///   baseUrl: Uri.parse('http://localhost:4096'),")
      ..writeln('/// );')
      ..writeln('/// final session = await client.session.create();')
      ..writeln(
        "/// await client.session.prompt(sessionID: session.id, text: 'Hi');",
      )
      ..writeln('/// ```')
      ..writeln('final class OpenCodeClient {')
      ..writeln('  /// Creates a client for [baseUrl].')
      ..writeln('  OpenCodeClient({')
      ..writeln('    required Uri baseUrl,')
      ..writeln('    Map<String, String>? headers,')
      ..writeln('    http.Client? httpClient,')
      ..writeln('    http.Client Function()? clientFactory,')
      ..writeln('  }) : transport = OpenCodeTransport(')
      ..writeln('          baseUrl: baseUrl,')
      ..writeln('          headers: headers,')
      ..writeln('          httpClient: httpClient,')
      ..writeln('          clientFactory: clientFactory,')
      ..writeln('        ) {')
      ..writeln('    transport.exceptionDecoder = decodeOpenCodeException;')
      ..writeln('  }')
      ..writeln()
      ..writeln('  /// Creates a client for [baseUrl].')
      ..writeln('  static OpenCodeClient make({')
      ..writeln('    required Uri baseUrl,')
      ..writeln('    Map<String, String>? headers,')
      ..writeln('    http.Client? httpClient,')
      ..writeln('  }) =>')
      ..writeln('      OpenCodeClient(')
      ..writeln('        baseUrl: baseUrl,')
      ..writeln('        headers: headers,')
      ..writeln('        httpClient: httpClient,')
      ..writeln('      );')
      ..writeln()
      ..writeln(
          '  /// Discovers (or starts) the local background service and returns')
      ..writeln('  /// an authenticated client.')
      ..writeln('  static Future<OpenCodeClient> connectLocal({')
      ..writeln('    EnsureOptions options = const EnsureOptions(),')
      ..writeln('  }) async {')
      ..writeln('    final endpoint =')
      ..writeln('        await OpenCodeService.discover(options: options) ??')
      ..writeln('            await OpenCodeService.ensure(options: options);')
      ..writeln('    return OpenCodeClient(')
      ..writeln('      baseUrl: endpoint.url,')
      ..writeln('      headers: OpenCodeService.headers(endpoint),')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  /// The HTTP transport. Every resource shares it.')
      ..writeln('  final OpenCodeTransport transport;')
      ..writeln()
      ..writeln(
          '  late final EventMultiplexer _multiplexer = EventMultiplexer(')
      ..writeln('    (token, onActivity) => transport')
      ..writeln('        .sseFrames(')
      ..writeln("          path: '/api/event',")
      ..writeln('          options: RequestOptions(cancelToken: token),')
      ..writeln('          onActivity: onActivity,')
      ..writeln('        )')
      ..writeln('        .map(')
      ..writeln('          (frame) => OpenCodeEvent.fromJson(')
      ..writeln('            asJsonMap(unwrapEmbeddedJson(frame)),')
      ..writeln('          ),')
      ..writeln('        ),')
      ..writeln('  );')
      ..writeln()
      ..writeln('  /// The shared event multiplexer.')
      ..writeln('  EventMultiplexer get multiplexer => _multiplexer;')
      ..writeln()
      ..writeln('  /// Creates a typed subclient for a plugin RPC.')
      ..writeln('  RpcSubClient rpc(String id) =>')
      ..writeln(
        '      RpcSubClient(id: id, transport: transport, events: _multiplexer);',
      )
      ..writeln();

    for (final tag in _resourceTags) {
      if (tag == 'rpc') continue;
      final getter = camelCase(tag);
      final className = '${pascalCase(tag)}Resource';
      if (tag == 'event') {
        file
          ..writeln('  /// The `event` resource.')
          ..writeln(
            '  late final $className $getter = $className(transport, _multiplexer);',
          )
          ..writeln()
          ..writeln(
              '  /// Alias for [event], matching the SDK convenience group.')
          ..writeln('  $className get events => $getter;')
          ..writeln();
        continue;
      }
      file
        ..writeln('  /// The `$tag` resource.')
        ..writeln('  late final $className $getter = $className(transport);')
        ..writeln();
      if (tag == 'session') {
        file
          ..writeln('  /// Alias for [session].')
          ..writeln('  $className get sessions => $getter;')
          ..writeln();
      }
      if (tag == 'filesystem') {
        file
          ..writeln('  /// Alias for [filesystem].')
          ..writeln('  $className get file => $getter;')
          ..writeln();
      }
    }

    file
      ..writeln(
          '  /// Closes the client, aborting the shared event connection.')
      ..writeln('  void close() {')
      ..writeln('    _multiplexer.dispose();')
      ..writeln('    transport.close();')
      ..writeln('  }')
      ..writeln('}')
      ..writeln()
      ..writeln('/// The OpenCode client entry point.')
      ..writeln('abstract final class OpenCode {')
      ..writeln('  /// Creates a client for [baseUrl].')
      ..writeln('  static OpenCodeClient make({')
      ..writeln('    required Uri baseUrl,')
      ..writeln('    Map<String, String>? headers,')
      ..writeln('    http.Client? httpClient,')
      ..writeln('  }) =>')
      ..writeln('      OpenCodeClient.make(')
      ..writeln('        baseUrl: baseUrl,')
      ..writeln('        headers: headers,')
      ..writeln('        httpClient: httpClient,')
      ..writeln('      );')
      ..writeln()
      ..writeln(
          '  /// Discovers the local background service and returns a client.')
      ..writeln('  static Future<OpenCodeClient> connectLocal({')
      ..writeln('    EnsureOptions options = const EnsureOptions(),')
      ..writeln('  }) =>')
      ..writeln('      OpenCodeClient.connectLocal(options: options);')
      ..writeln('}');

    File('lib/src/generated/client.dart').writeAsStringSync(file.toString());
  }
}

// ---------------------------------------------------------------------------
// Planning records
// ---------------------------------------------------------------------------

final class _Parameter {
  _Parameter({
    required this.name,
    required this.dartName,
    required this.type,
    required this.required,
  });

  final String name;
  final String dartName;
  final CType type;
  final bool required;
}

final class _BodyParameter {
  _BodyParameter({
    required this.kind,
    required this.fields,
    this.rawArguments = const {},
  });

  final _BodyKind kind;
  final List<ObjectProperty> fields;
  final Map<String, String> rawArguments;
}

enum _BodyKind { object, raw, binary }

final class _ResponseSpec {
  const _ResponseSpec({
    required this.returnType,
    required this.kind,
    this.decodeType,
    this.status = 200,
  });

  final String returnType;
  final _ResponseKind kind;
  final CType? decodeType;
  final int status;
}

enum _ResponseKind {
  empty,
  direct,
  data,
  located,
  binary,
  nullableValue,
  sseEvents,
  sseJson
}

final class _OperationPlan {
  _OperationPlan({
    required this.signature,
    required this.body,
    required this.isAsync,
  });

  final String signature;
  final String body;
  final bool isAsync;
}

final class _Operation {
  _Operation({
    required this.method,
    required this.path,
    required this.operationId,
    required this.operation,
  });

  final String method;
  final String path;
  final String operationId;
  final Map<String, dynamic> operation;
  String? methodName;
  _OperationPlan? plan;

  String get methodId => pascalCase(operationId);
}

final class _MethodNode {
  _MethodNode({required this.name, required this.className});

  final String name;
  final String className;
  final Map<String, _MethodNode> children = {};
  final List<_Operation> operations = [];
}
