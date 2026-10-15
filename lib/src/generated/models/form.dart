// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// `Form.BooleanField`
final class FormBooleanField extends FormField {
  const FormBooleanField({
    required this.key,
    this.title,
    this.description,
    this.required,
    this.hidden,
    this.when,
    this.defaultValue,
  });

  factory FormBooleanField.fromJson(Map<String, Object?> json) =>
      FormBooleanField(
        key: decodeString(json, 'key'),
        title: decodeOptionalString(json, 'title'),
        description: decodeOptionalString(json, 'description'),
        required: decodeOptionalBool(json, 'required'),
        hidden: decodeOptionalBool(json, 'hidden'),
        when: json['when'] == null
            ? null
            : jsonList(
                json['when'], (item) => FormWhen.fromJson(asJsonMap(item))),
        defaultValue: decodeOptionalBool(json, 'default'),
      );

  @override
  final String key;
  @override
  final String? title;
  @override
  final String? description;
  final bool? required;
  final bool? hidden;
  final List<FormWhen>? when;

  /// Wire field: `default`.
  final bool? defaultValue;

  /// Always `boolean`.
  @override
  String get type => 'boolean';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        if (title != null) 'title': title!,
        if (description != null) 'description': description!,
        if (required != null) 'required': required!,
        if (hidden != null) 'hidden': hidden!,
        if (when != null) 'when': [for (final item in when!) item.toJson()],
        'type': 'boolean',
        if (defaultValue != null) 'default': defaultValue!,
      };
}

/// `Form.When`
final class FormWhen {
  const FormWhen({
    required this.key,
    required this.op,
    required this.value,
  });

  factory FormWhen.fromJson(Map<String, Object?> json) => FormWhen(
        key: decodeString(json, 'key'),
        op: FormWhenOp.fromJson(json['op']),
        value: json['value'],
      );

  final String key;
  final FormWhenOp op;
  final Object? value;

  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        'op': op.wire,
        'value': value,
      };
}

/// `Form.CreatePayload`
final class FormCreatePayload {
  const FormCreatePayload({
    this.id,
    required this.title,
    this.metadata,
    required this.fields,
  });

  factory FormCreatePayload.fromJson(Map<String, Object?> json) =>
      FormCreatePayload(
        id: json['id'] == null
            ? null
            : FormID.fromJson(asJsonString(json['id'])),
        title: decodeString(json, 'title'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        fields: jsonList(
            json['fields'], (item) => FormField.fromJson(asJsonMap(item))),
      );

  final FormID? id;
  final String title;
  final Map<String, Object?>? metadata;
  final List<FormField> fields;

  Map<String, Object?> toJson() => <String, Object?>{
        if (id != null) 'id': id!,
        'title': title,
        if (metadata != null) 'metadata': metadata!,
        'fields': [for (final item in fields) item.toJson()],
      };
}

/// `Form.Field`
sealed class FormField {
  const FormField();

  /// Decodes a payload into the matching variant.
  factory FormField.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'string' => FormStringField.fromJson(json),
      'number' => FormNumberField.fromJson(json),
      'integer' => FormIntegerField.fromJson(json),
      'boolean' => FormBooleanField.fromJson(json),
      'multiselect' => FormMultiselectField.fromJson(json),
      'external' => FormExternalField.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Form.Field discriminator: $value'),
    };
  }

  /// Present on every variant (`key`).
  String get key;

  /// Present on every variant (`title`).
  String? get title;

  /// Present on every variant (`description`).
  String? get description;

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Form.StringField`
final class FormStringField extends FormField {
  const FormStringField({
    required this.key,
    this.title,
    this.description,
    this.required,
    this.hidden,
    this.when,
    this.format,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.placeholder,
    this.defaultValue,
    this.options,
    this.custom,
  });

  factory FormStringField.fromJson(Map<String, Object?> json) =>
      FormStringField(
        key: decodeString(json, 'key'),
        title: decodeOptionalString(json, 'title'),
        description: decodeOptionalString(json, 'description'),
        required: decodeOptionalBool(json, 'required'),
        hidden: decodeOptionalBool(json, 'hidden'),
        when: json['when'] == null
            ? null
            : jsonList(
                json['when'], (item) => FormWhen.fromJson(asJsonMap(item))),
        format: json['format'] == null
            ? null
            : FormStringFieldFormat.fromJson(json['format']),
        minLength: decodeOptionalInt(json, 'minLength'),
        maxLength: decodeOptionalInt(json, 'maxLength'),
        pattern: decodeOptionalString(json, 'pattern'),
        placeholder: decodeOptionalString(json, 'placeholder'),
        defaultValue: decodeOptionalString(json, 'default'),
        options: json['options'] == null
            ? null
            : jsonList(json['options'],
                (item) => FormOption.fromJson(asJsonMap(item))),
        custom: decodeOptionalBool(json, 'custom'),
      );

  @override
  final String key;
  @override
  final String? title;
  @override
  final String? description;
  final bool? required;
  final bool? hidden;
  final List<FormWhen>? when;
  final FormStringFieldFormat? format;
  final int? minLength;
  final int? maxLength;
  final String? pattern;
  final String? placeholder;

  /// Wire field: `default`.
  final String? defaultValue;
  final List<FormOption>? options;
  final bool? custom;

  /// Always `string`.
  @override
  String get type => 'string';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        if (title != null) 'title': title!,
        if (description != null) 'description': description!,
        if (required != null) 'required': required!,
        if (hidden != null) 'hidden': hidden!,
        if (when != null) 'when': [for (final item in when!) item.toJson()],
        'type': 'string',
        if (format != null) 'format': format!.wire,
        if (minLength != null) 'minLength': minLength!,
        if (maxLength != null) 'maxLength': maxLength!,
        if (pattern != null) 'pattern': pattern!,
        if (placeholder != null) 'placeholder': placeholder!,
        if (defaultValue != null) 'default': defaultValue!,
        if (options != null)
          'options': [for (final item in options!) item.toJson()],
        if (custom != null) 'custom': custom!,
      };
}

/// `Form.Option`
final class FormOption {
  const FormOption({
    required this.value,
    required this.label,
    this.description,
  });

  factory FormOption.fromJson(Map<String, Object?> json) => FormOption(
        value: decodeString(json, 'value'),
        label: decodeString(json, 'label'),
        description: decodeOptionalString(json, 'description'),
      );

  final String value;
  final String label;
  final String? description;

  Map<String, Object?> toJson() => <String, Object?>{
        'value': value,
        'label': label,
        if (description != null) 'description': description!,
      };
}

/// `Form.NumberField`
final class FormNumberField extends FormField {
  const FormNumberField({
    required this.key,
    this.title,
    this.description,
    this.required,
    this.hidden,
    this.when,
    this.minimum,
    this.maximum,
    this.defaultValue,
  });

  factory FormNumberField.fromJson(Map<String, Object?> json) =>
      FormNumberField(
        key: decodeString(json, 'key'),
        title: decodeOptionalString(json, 'title'),
        description: decodeOptionalString(json, 'description'),
        required: decodeOptionalBool(json, 'required'),
        hidden: decodeOptionalBool(json, 'hidden'),
        when: json['when'] == null
            ? null
            : jsonList(
                json['when'], (item) => FormWhen.fromJson(asJsonMap(item))),
        minimum: json['minimum'],
        maximum: json['maximum'],
        defaultValue: json['default'],
      );

  @override
  final String key;
  @override
  final String? title;
  @override
  final String? description;
  final bool? required;
  final bool? hidden;
  final List<FormWhen>? when;
  final Object? minimum;
  final Object? maximum;

  /// Wire field: `default`.
  final Object? defaultValue;

  /// Always `number`.
  @override
  String get type => 'number';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        if (title != null) 'title': title!,
        if (description != null) 'description': description!,
        if (required != null) 'required': required!,
        if (hidden != null) 'hidden': hidden!,
        if (when != null) 'when': [for (final item in when!) item.toJson()],
        'type': 'number',
        if (minimum != null) 'minimum': minimum!,
        if (maximum != null) 'maximum': maximum!,
        if (defaultValue != null) 'default': defaultValue!,
      };
}

/// `Form.IntegerField`
final class FormIntegerField extends FormField {
  const FormIntegerField({
    required this.key,
    this.title,
    this.description,
    this.required,
    this.hidden,
    this.when,
    this.minimum,
    this.maximum,
    this.defaultValue,
  });

  factory FormIntegerField.fromJson(Map<String, Object?> json) =>
      FormIntegerField(
        key: decodeString(json, 'key'),
        title: decodeOptionalString(json, 'title'),
        description: decodeOptionalString(json, 'description'),
        required: decodeOptionalBool(json, 'required'),
        hidden: decodeOptionalBool(json, 'hidden'),
        when: json['when'] == null
            ? null
            : jsonList(
                json['when'], (item) => FormWhen.fromJson(asJsonMap(item))),
        minimum: json['minimum'],
        maximum: json['maximum'],
        defaultValue: json['default'],
      );

  @override
  final String key;
  @override
  final String? title;
  @override
  final String? description;
  final bool? required;
  final bool? hidden;
  final List<FormWhen>? when;
  final Object? minimum;
  final Object? maximum;

  /// Wire field: `default`.
  final Object? defaultValue;

  /// Always `integer`.
  @override
  String get type => 'integer';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        if (title != null) 'title': title!,
        if (description != null) 'description': description!,
        if (required != null) 'required': required!,
        if (hidden != null) 'hidden': hidden!,
        if (when != null) 'when': [for (final item in when!) item.toJson()],
        'type': 'integer',
        if (minimum != null) 'minimum': minimum!,
        if (maximum != null) 'maximum': maximum!,
        if (defaultValue != null) 'default': defaultValue!,
      };
}

/// `Form.MultiselectField`
final class FormMultiselectField extends FormField {
  const FormMultiselectField({
    required this.key,
    this.title,
    this.description,
    this.required,
    this.hidden,
    this.when,
    required this.options,
    this.minItems,
    this.maxItems,
    this.custom,
    this.defaultValue,
  });

  factory FormMultiselectField.fromJson(Map<String, Object?> json) =>
      FormMultiselectField(
        key: decodeString(json, 'key'),
        title: decodeOptionalString(json, 'title'),
        description: decodeOptionalString(json, 'description'),
        required: decodeOptionalBool(json, 'required'),
        hidden: decodeOptionalBool(json, 'hidden'),
        when: json['when'] == null
            ? null
            : jsonList(
                json['when'], (item) => FormWhen.fromJson(asJsonMap(item))),
        options: jsonList(
            json['options'], (item) => FormOption.fromJson(asJsonMap(item))),
        minItems: decodeOptionalInt(json, 'minItems'),
        maxItems: decodeOptionalInt(json, 'maxItems'),
        custom: decodeOptionalBool(json, 'custom'),
        defaultValue: json['default'] == null
            ? null
            : jsonList(json['default'], (item) => asJsonString(item)),
      );

  @override
  final String key;
  @override
  final String? title;
  @override
  final String? description;
  final bool? required;
  final bool? hidden;
  final List<FormWhen>? when;
  final List<FormOption> options;
  final int? minItems;
  final int? maxItems;
  final bool? custom;

  /// Wire field: `default`.
  final List<String>? defaultValue;

  /// Always `multiselect`.
  @override
  String get type => 'multiselect';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        if (title != null) 'title': title!,
        if (description != null) 'description': description!,
        if (required != null) 'required': required!,
        if (hidden != null) 'hidden': hidden!,
        if (when != null) 'when': [for (final item in when!) item.toJson()],
        'type': 'multiselect',
        'options': [for (final item in options) item.toJson()],
        if (minItems != null) 'minItems': minItems!,
        if (maxItems != null) 'maxItems': maxItems!,
        if (custom != null) 'custom': custom!,
        if (defaultValue != null) 'default': defaultValue!,
      };
}

/// `Form.ExternalField`
final class FormExternalField extends FormField {
  const FormExternalField({
    required this.key,
    required this.url,
    this.title,
    this.description,
  });

  factory FormExternalField.fromJson(Map<String, Object?> json) =>
      FormExternalField(
        key: decodeString(json, 'key'),
        url: decodeString(json, 'url'),
        title: decodeOptionalString(json, 'title'),
        description: decodeOptionalString(json, 'description'),
      );

  @override
  final String key;
  final String url;
  @override
  final String? title;
  @override
  final String? description;

  /// Always `external`.
  @override
  String get type => 'external';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        'type': 'external',
        'url': url,
        if (title != null) 'title': title!,
        if (description != null) 'description': description!,
      };
}

/// `Form.Detail`
final class FormDetail {
  const FormDetail({
    required this.id,
    required this.sessionID,
    required this.title,
    this.metadata,
    required this.fields,
    required this.state,
  });

  factory FormDetail.fromJson(Map<String, Object?> json) => FormDetail(
        id: FormID.fromJson(asJsonString(json['id'])),
        sessionID: decodeString(json, 'sessionID'),
        title: decodeString(json, 'title'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        fields: jsonList(
            json['fields'], (item) => FormField.fromJson(asJsonMap(item))),
        state: FormState.fromJson(asJsonMap(json['state'])),
      );

  final FormID id;
  final String sessionID;
  final String title;
  final Map<String, Object?>? metadata;
  final List<FormField> fields;
  final FormState state;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'sessionID': sessionID,
        'title': title,
        if (metadata != null) 'metadata': metadata!,
        'fields': [for (final item in fields) item.toJson()],
        'state': state.toJson(),
      };
}

/// `Form.State`
sealed class FormState {
  const FormState();

  /// Decodes a payload into the matching variant.
  factory FormState.fromJson(Map<String, Object?> json) {
    final value = json['status'];
    return switch (value) {
      'pending' => FormStatePending.fromJson(json),
      'answered' => FormStateAnswered.fromJson(json),
      'cancelled' => FormStateCancelled.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Form.State discriminator: $value'),
    };
  }

  /// Present on every variant (`status`).
  String get status;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `FormStatePending`
final class FormStatePending extends FormState {
  const FormStatePending();

  factory FormStatePending.fromJson(Map<String, Object?> json) =>
      FormStatePending();

  /// Always `pending`.
  @override
  String get status => 'pending';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'pending',
      };
}

/// `FormStateAnswered`
final class FormStateAnswered extends FormState {
  const FormStateAnswered({
    required this.answer,
  });

  factory FormStateAnswered.fromJson(Map<String, Object?> json) =>
      FormStateAnswered(
        answer: asJsonMap(json['answer']),
      );

  final Map<String, Object?> answer;

  /// Always `answered`.
  @override
  String get status => 'answered';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'answered',
        'answer': answer,
      };
}

/// `FormStateCancelled`
final class FormStateCancelled extends FormState {
  const FormStateCancelled({
    this.message,
  });

  factory FormStateCancelled.fromJson(Map<String, Object?> json) =>
      FormStateCancelled(
        message: decodeOptionalString(json, 'message'),
      );

  final String? message;

  /// Always `cancelled`.
  @override
  String get status => 'cancelled';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'cancelled',
        if (message != null) 'message': message!,
      };
}

/// `Form.Info`
final class FormInfo {
  const FormInfo({
    required this.id,
    required this.sessionID,
    required this.title,
    this.metadata,
    required this.fields,
  });

  factory FormInfo.fromJson(Map<String, Object?> json) => FormInfo(
        id: FormID.fromJson(asJsonString(json['id'])),
        sessionID: decodeString(json, 'sessionID'),
        title: decodeString(json, 'title'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        fields: jsonList(
            json['fields'], (item) => FormField.fromJson(asJsonMap(item))),
      );

  final FormID id;
  final String sessionID;
  final String title;
  final Map<String, Object?>? metadata;
  final List<FormField> fields;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'sessionID': sessionID,
        'title': title,
        if (metadata != null) 'metadata': metadata!,
        'fields': [for (final item in fields) item.toJson()],
      };
}

/// `Form.Reply`
final class FormReply {
  const FormReply({
    required this.answer,
  });

  factory FormReply.fromJson(Map<String, Object?> json) => FormReply(
        answer: asJsonMap(json['answer']),
      );

  final Map<String, Object?> answer;

  Map<String, Object?> toJson() => <String, Object?>{
        'answer': answer,
      };
}
