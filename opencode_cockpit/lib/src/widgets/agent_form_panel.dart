import 'package:flutter/material.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart' as sdk;

/// Renders one agent-authored form (session.form.get) and collects an answer.
///
/// The panel keeps its own draft state, hides fields whose `when` conditions
/// fail against the current draft, and reports the answer map through
/// [onReply], keyed by field key. External fields are informational only and
/// are never part of the answer.
class AgentFormPanel extends StatefulWidget {
  const AgentFormPanel({
    super.key,
    required this.detail,
    required this.onReply,
    required this.onCancel,
    this.busy = false,
  });

  /// The form definition returned by `session.form.get`.
  final sdk.FormDetail detail;

  /// Called with the answer map keyed by field key.
  final void Function(Map<String, Object?> answer) onReply;

  /// Called when the user dismisses the form without answering.
  final VoidCallback onCancel;

  /// Whether a reply is currently in flight.
  final bool busy;

  /// Defaults for all fields with a `defaultValue` (also used by the host).
  static Map<String, Object?> initialAnswers(sdk.FormDetail detail) {
    final answers = <String, Object?>{};
    for (final field in detail.fields) {
      switch (field) {
        case sdk.FormStringField(:final key, :final defaultValue):
          if (defaultValue != null && defaultValue.isNotEmpty) {
            answers[key] = defaultValue;
          }
        case sdk.FormNumberField(:final key, :final defaultValue) ||
            sdk.FormIntegerField(:final key, :final defaultValue):
          if (defaultValue != null) {
            answers[key] = defaultValue;
          }
        case sdk.FormBooleanField(:final key, :final defaultValue):
          if (defaultValue != null) {
            answers[key] = defaultValue;
          }
        case sdk.FormMultiselectField(:final key, :final defaultValue):
          if (defaultValue != null && defaultValue.isNotEmpty) {
            answers[key] = List<String>.of(defaultValue);
          }
        case sdk.FormExternalField():
          break;
      }
    }
    return answers;
  }

  @override
  State<AgentFormPanel> createState() => _AgentFormPanelState();
}

class _AgentFormPanelState extends State<AgentFormPanel> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _texts = {};
  final Map<String, TextEditingController> _customs = {};
  final Map<String, Object?> _answers = {};
  bool _submitted = false;

  bool get _readOnly => widget.detail.state.status != 'pending';

  @override
  void initState() {
    super.initState();
    _seed();
  }

  @override
  void didUpdateWidget(covariant AgentFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail.id != widget.detail.id) {
      _disposeControllers();
      _submitted = false;
      _seed();
      return;
    }
    if (oldWidget.detail.state.status != widget.detail.state.status) {
      _answers
        ..clear()
        ..addAll(AgentFormPanel.initialAnswers(widget.detail));
      final state = widget.detail.state;
      if (state is sdk.FormStateAnswered) _applyAnswer(state.answer);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final controller in _texts.values) {
      controller.dispose();
    }
    for (final controller in _customs.values) {
      controller.dispose();
    }
    _texts.clear();
    _customs.clear();
  }

  void _seed() {
    _answers
      ..clear()
      ..addAll(AgentFormPanel.initialAnswers(widget.detail));
    for (final field in widget.detail.fields) {
      switch (field) {
        case sdk.FormStringField(
          :final key,
          :final options,
          :final defaultValue,
        ):
          if (options == null || options.isEmpty) {
            _texts[key] = TextEditingController(text: defaultValue ?? '');
          }
        case sdk.FormNumberField(:final key, :final defaultValue) ||
            sdk.FormIntegerField(:final key, :final defaultValue):
          _texts[key] = TextEditingController(text: _numberText(defaultValue));
        case sdk.FormMultiselectField(:final key, :final custom):
          if (custom == true) _customs[key] = TextEditingController();
        case _:
          break;
      }
    }
    final state = widget.detail.state;
    if (state is sdk.FormStateAnswered) _applyAnswer(state.answer);
  }

  /// Overlays a server answer (read-only rendering) onto the draft state.
  void _applyAnswer(Map<String, Object?> answer) {
    for (final field in widget.detail.fields) {
      if (!answer.containsKey(field.key)) continue;
      final value = answer[field.key];
      switch (field) {
        case sdk.FormStringField(:final key):
          final text = value == null ? '' : '$value';
          _texts[key]?.text = text;
          if (text.isNotEmpty) _answers[key] = value;
        case sdk.FormNumberField(:final key) ||
            sdk.FormIntegerField(:final key):
          final text = _numberText(value);
          _texts[key]?.text = text;
          if (text.isNotEmpty) _answers[key] = value;
        case sdk.FormBooleanField(:final key):
          if (value is bool) _answers[key] = value;
        case sdk.FormMultiselectField(:final key):
          final values = switch (value) {
            List() => [for (final item in value) '$item'],
            String() => [value],
            _ => const <String>[],
          };
          if (values.isNotEmpty) _answers[key] = values;
        case sdk.FormExternalField():
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[_header(theme)];
    for (final field in widget.detail.fields) {
      if (!_visible(field)) continue;
      children
        ..add(const SizedBox(height: 12))
        ..add(_buildField(theme, field));
    }
    children
      ..add(const SizedBox(height: 14))
      ..add(_footer());
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _header(ThemeData theme) {
    final state = widget.detail.state;
    final (Color background, Color foreground) = switch (state) {
      sdk.FormStatePending() => (
        theme.colorScheme.tertiaryContainer.withValues(alpha: 0.45),
        theme.colorScheme.tertiary,
      ),
      sdk.FormStateAnswered() => (
        theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        theme.colorScheme.primary,
      ),
      sdk.FormStateCancelled() => (
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.outline,
      ),
    };
    return Row(
      children: [
        Icon(
          Icons.dynamic_form_outlined,
          size: 16,
          color: theme.colorScheme.tertiary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.detail.title,
            style: theme.textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            state.status,
            style: theme.textTheme.labelSmall?.copyWith(color: foreground),
          ),
        ),
      ],
    );
  }

  Widget _footer() {
    return Row(
      children: [
        const Spacer(),
        TextButton(
          key: const ValueKey('form-cancel'),
          onPressed: widget.busy ? null : widget.onCancel,
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          key: const ValueKey('form-submit'),
          onPressed: _readOnly || widget.busy || !_canSubmit ? null : _submit,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.busy) ...[
                const SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(strokeWidth: 1.8),
                ),
                const SizedBox(width: 8),
              ],
              const Text('Submit'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField(ThemeData theme, sdk.FormField field) {
    return switch (field) {
      sdk.FormStringField() => _stringField(theme, field),
      sdk.FormNumberField() => _numberField(theme, field),
      sdk.FormIntegerField() => _integerField(theme, field),
      sdk.FormBooleanField() => _booleanField(theme, field),
      sdk.FormMultiselectField() => _multiselectField(theme, field),
      sdk.FormExternalField() => _externalField(theme, field),
    };
  }

  Widget _stringField(ThemeData theme, sdk.FormStringField field) {
    final options = field.options;
    if (options != null && options.isNotEmpty) {
      return DropdownButtonFormField<String>(
        key: ValueKey('form-field-${field.key}'),
        initialValue: _dropdownValue(field),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option.value, child: Text(option.label)),
        ],
        onChanged: _readOnly
            ? null
            : (value) => setState(() {
                if (value == null || value.isEmpty) {
                  _answers.remove(field.key);
                } else {
                  _answers[field.key] = value;
                }
              }),
        validator: (value) =>
            field.required == true && (value == null || value.isEmpty)
            ? 'Required'
            : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: _label(field),
          helperText: field.description,
        ),
      );
    }
    final maxLength = field.maxLength;
    return TextFormField(
      key: ValueKey('form-field-${field.key}'),
      controller: _texts[field.key],
      enabled: !_readOnly,
      keyboardType: _stringKeyboard(field),
      textInputAction: TextInputAction.next,
      maxLength: maxLength != null && maxLength > 0 ? maxLength : null,
      onChanged: (value) => _setTextAnswer(field, value),
      validator: (value) => _stringError(field, value),
      decoration: InputDecoration(
        labelText: _label(field),
        hintText: field.placeholder,
        helperText: field.description,
        counterText: maxLength != null && maxLength > 0 ? '' : null,
        isDense: true,
      ),
    );
  }

  Widget _numberField(ThemeData theme, sdk.FormNumberField field) {
    return TextFormField(
      key: ValueKey('form-field-${field.key}'),
      controller: _texts[field.key],
      enabled: !_readOnly,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      textInputAction: TextInputAction.next,
      onChanged: (value) => _setTextAnswer(field, value),
      validator: (value) => _numberError(field, value),
      decoration: InputDecoration(
        labelText: _label(field),
        helperText: field.description,
        isDense: true,
      ),
    );
  }

  Widget _integerField(ThemeData theme, sdk.FormIntegerField field) {
    return TextFormField(
      key: ValueKey('form-field-${field.key}'),
      controller: _texts[field.key],
      enabled: !_readOnly,
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      textInputAction: TextInputAction.next,
      onChanged: (value) => _setTextAnswer(field, value),
      validator: (value) => _integerError(field, value),
      decoration: InputDecoration(
        labelText: _label(field),
        helperText: field.description,
        isDense: true,
      ),
    );
  }

  Widget _booleanField(ThemeData theme, sdk.FormBooleanField field) {
    final value = _answers[field.key];
    return Material(
      type: MaterialType.transparency,
      child: CheckboxListTile(
        key: ValueKey('form-field-${field.key}'),
        value: value is bool && value,
        onChanged: _readOnly
            ? null
            : (checked) => setState(() {
                _answers[field.key] = checked ?? false;
              }),
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        visualDensity: VisualDensity.compact,
        title: Text(_label(field), style: theme.textTheme.bodyMedium),
        subtitle: field.description == null
            ? null
            : Text(
                field.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }

  Widget _multiselectField(ThemeData theme, sdk.FormMultiselectField field) {
    final selected = _selectedValues(field.key);
    final optionValues = {for (final option in field.options) option.value};
    final customValues = selected
        .where((value) => !optionValues.contains(value))
        .toList();
    final error = _submitted ? _multiselectError(field) : null;
    final maxItems = field.maxItems;
    final maxReached = maxItems != null && selected.length >= maxItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_label(field), style: theme.textTheme.bodyMedium),
        if (field.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              field.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final option in field.options)
              FilterChip(
                key: ValueKey('form-chip-${field.key}-${option.value}'),
                label: Text(option.label),
                selected: selected.contains(option.value),
                visualDensity: VisualDensity.compact,
                onSelected:
                    _readOnly ||
                        (maxReached && !selected.contains(option.value))
                    ? null
                    : (on) => _toggleSelection(field.key, option.value, on),
              ),
            for (final value in customValues)
              InputChip(
                key: ValueKey('form-chip-${field.key}-$value'),
                label: Text(value),
                visualDensity: VisualDensity.compact,
                onDeleted: _readOnly
                    ? null
                    : () => _toggleSelection(field.key, value, false),
              ),
          ],
        ),
        if (field.custom == true && !_readOnly) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: ValueKey('form-custom-${field.key}'),
                  controller: _customs[field.key],
                  decoration: const InputDecoration(
                    hintText: 'Add custom value',
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) => _addCustom(field, value),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                key: ValueKey('form-custom-add-${field.key}'),
                tooltip: 'Add custom value',
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    _addCustom(field, _customs[field.key]?.text ?? ''),
                icon: const Icon(Icons.add_rounded, size: 16),
              ),
            ],
          ),
        ],
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _externalField(ThemeData theme, sdk.FormExternalField field) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.open_in_new_rounded,
            size: 15,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_label(field), style: theme.textTheme.bodyMedium),
                if (field.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      field.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                SelectableText(
                  field.url,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'AppMono',
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Complete this step outside the app; it is not part of '
                  'the reply.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_canSubmit) return;
    setState(() => _submitted = true);
    final valid = _formKey.currentState?.validate() ?? true;
    final selectionsValid = widget.detail.fields
        .whereType<sdk.FormMultiselectField>()
        .where(_visible)
        .every((field) => _multiselectError(field) == null);
    if (!valid || !selectionsValid) return;
    widget.onReply(_buildAnswers());
  }

  bool get _canSubmit {
    for (final field in widget.detail.fields) {
      if (!_visible(field) || field is sdk.FormExternalField) continue;
      if (_required(field) && !_hasAnswer(field)) return false;
    }
    return true;
  }

  Map<String, Object?> _buildAnswers() {
    final result = <String, Object?>{};
    for (final field in widget.detail.fields) {
      if (!_visible(field)) continue;
      switch (field) {
        case sdk.FormExternalField():
          break;
        case sdk.FormStringField(:final key, :final options):
          if (options != null && options.isNotEmpty) {
            final value = _answers[key];
            if (value is String && value.isNotEmpty) result[key] = value;
          } else {
            final text = _texts[key]?.text ?? '';
            if (text.trim().isNotEmpty) result[key] = text;
          }
        case sdk.FormNumberField(:final key):
          final text = _texts[key]?.text.trim() ?? '';
          final value = double.tryParse(text);
          if (value != null && value.isFinite) result[key] = value;
        case sdk.FormIntegerField(:final key):
          final text = _texts[key]?.text.trim() ?? '';
          final value = int.tryParse(text);
          if (value != null) result[key] = value;
        case sdk.FormBooleanField(:final key):
          final value = _answers[key];
          if (value is bool) result[key] = value;
        case sdk.FormMultiselectField(:final key):
          final values = _selectedValues(key);
          if (values.isNotEmpty) result[key] = values;
      }
    }
    return result;
  }

  bool _visible(sdk.FormField field) {
    if (_hidden(field)) return false;
    final conditions = _when(field);
    if (conditions == null) return true;
    return conditions.every(_conditionPasses);
  }

  bool _conditionPasses(sdk.FormWhen condition) {
    final matches =
        _answers.containsKey(condition.key) &&
        _valuesEqual(_answers[condition.key], condition.value);
    return condition.op == sdk.FormWhenOp.eq ? matches : !matches;
  }

  bool _valuesEqual(Object? current, Object? expected) {
    if (current is List && expected is List) {
      if (current.length != expected.length) return false;
      for (var i = 0; i < current.length; i++) {
        if (current[i] != expected[i]) return false;
      }
      return true;
    }
    return current == expected;
  }

  bool _hasAnswer(sdk.FormField field) {
    return switch (field) {
      sdk.FormStringField(:final key, :final options) =>
        options == null || options.isEmpty
            ? (_texts[key]?.text.trim().isNotEmpty ?? false)
            : _answers[key] is String,
      sdk.FormNumberField(:final key) =>
        _texts[key]?.text.trim().isNotEmpty ?? false,
      sdk.FormIntegerField(:final key) =>
        _texts[key]?.text.trim().isNotEmpty ?? false,
      sdk.FormBooleanField(:final key) => _answers.containsKey(key),
      sdk.FormMultiselectField(:final key) => _selectedValues(key).isNotEmpty,
      sdk.FormExternalField() => true,
    };
  }

  String? _multiselectError(sdk.FormMultiselectField field) {
    final selected = _selectedValues(field.key);
    if (field.required == true && selected.isEmpty) {
      return 'Select at least one option';
    }
    final minItems = field.minItems;
    if (minItems != null && selected.isNotEmpty && selected.length < minItems) {
      return 'Select at least $minItems';
    }
    final maxItems = field.maxItems;
    if (maxItems != null && selected.length > maxItems) {
      return 'Select at most $maxItems';
    }
    return null;
  }

  void _setTextAnswer(sdk.FormField field, String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _answers.remove(field.key);
        return;
      }
      _answers[field.key] = switch (field) {
        sdk.FormNumberField() => double.tryParse(value.trim()) ?? value,
        sdk.FormIntegerField() => int.tryParse(value.trim()) ?? value,
        _ => value,
      };
    });
  }

  void _toggleSelection(String key, String value, bool selected) {
    setState(() {
      final values = _selectedValues(key);
      if (selected) {
        if (!values.contains(value)) values.add(value);
      } else {
        values.remove(value);
      }
      if (values.isEmpty) {
        _answers.remove(key);
      } else {
        _answers[key] = values;
      }
    });
  }

  void _addCustom(sdk.FormMultiselectField field, String raw) {
    final value = raw.trim();
    if (value.isEmpty) return;
    final values = _selectedValues(field.key);
    if (values.contains(value)) {
      _customs[field.key]?.clear();
      return;
    }
    final maxItems = field.maxItems;
    if (maxItems != null && values.length >= maxItems) return;
    _toggleSelection(field.key, value, true);
    _customs[field.key]?.clear();
  }

  List<String> _selectedValues(String key) {
    return [for (final item in (_answers[key] as List? ?? const [])) '$item'];
  }

  String? _dropdownValue(sdk.FormStringField field) {
    final value = _answers[field.key];
    if (value is! String || value.isEmpty) return null;
    for (final option in field.options ?? const <sdk.FormOption>[]) {
      if (option.value == value) return value;
    }
    return null;
  }

  String? _stringError(sdk.FormStringField field, String? value) {
    final text = value ?? '';
    if (text.trim().isEmpty) {
      return field.required == true ? 'Required' : null;
    }
    final minLength = field.minLength;
    if (minLength != null && text.length < minLength) {
      return 'At least $minLength characters';
    }
    return null;
  }

  String? _numberError(sdk.FormNumberField field, String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return field.required == true ? 'Required' : null;
    final parsed = double.tryParse(text);
    if (parsed == null || !parsed.isFinite) return 'Enter a number';
    final minimum = _asNum(field.minimum);
    if (minimum != null && parsed < minimum) {
      return 'Must be at least ${_boundLabel(minimum)}';
    }
    final maximum = _asNum(field.maximum);
    if (maximum != null && parsed > maximum) {
      return 'Must be at most ${_boundLabel(maximum)}';
    }
    return null;
  }

  String? _integerError(sdk.FormIntegerField field, String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return field.required == true ? 'Required' : null;
    final parsed = int.tryParse(text);
    if (parsed == null) return 'Enter a whole number';
    final minimum = _asNum(field.minimum)?.ceil();
    if (minimum != null && parsed < minimum) {
      return 'Must be at least ${_boundLabel(minimum)}';
    }
    final maximum = _asNum(field.maximum)?.floor();
    if (maximum != null && parsed > maximum) {
      return 'Must be at most ${_boundLabel(maximum)}';
    }
    return null;
  }

  TextInputType? _stringKeyboard(sdk.FormStringField field) {
    return switch (field.format) {
      sdk.FormStringFieldFormat.email => TextInputType.emailAddress,
      sdk.FormStringFieldFormat.uri => TextInputType.url,
      _ => null,
    };
  }

  String _label(sdk.FormField field) {
    final title = field.title;
    if (title != null && title.trim().isNotEmpty) return title;
    return field.key;
  }
}

bool _hidden(sdk.FormField field) {
  return switch (field) {
    sdk.FormStringField(:final hidden) => hidden ?? false,
    sdk.FormNumberField(:final hidden) => hidden ?? false,
    sdk.FormIntegerField(:final hidden) => hidden ?? false,
    sdk.FormBooleanField(:final hidden) => hidden ?? false,
    sdk.FormMultiselectField(:final hidden) => hidden ?? false,
    sdk.FormExternalField() => false,
  };
}

List<sdk.FormWhen>? _when(sdk.FormField field) {
  return switch (field) {
    sdk.FormStringField(when: final conditions) => conditions,
    sdk.FormNumberField(when: final conditions) => conditions,
    sdk.FormIntegerField(when: final conditions) => conditions,
    sdk.FormBooleanField(when: final conditions) => conditions,
    sdk.FormMultiselectField(when: final conditions) => conditions,
    sdk.FormExternalField() => null,
  };
}

bool _required(sdk.FormField field) {
  return switch (field) {
    sdk.FormStringField(:final required) => required == true,
    sdk.FormNumberField(:final required) => required == true,
    sdk.FormIntegerField(:final required) => required == true,
    sdk.FormBooleanField(:final required) => required == true,
    sdk.FormMultiselectField(:final required) => required == true,
    sdk.FormExternalField() => false,
  };
}

String _numberText(Object? value) {
  if (value is int) return '$value';
  if (value is double) {
    return value == value.truncateToDouble() && value.isFinite
        ? value.toStringAsFixed(0)
        : '$value';
  }
  return value == null ? '' : '$value';
}

num? _asNum(Object? value) => value is num ? value : num.tryParse('$value');

String _boundLabel(num value) {
  return value.isFinite && value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : '$value';
}
