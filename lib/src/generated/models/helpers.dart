// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// Decodes a JSON array with [convert].
List<T> jsonList<T>(Object? value, T Function(Object? item) convert) =>
    [for (final item in asJsonList(value)) convert(item)];

/// Decodes a JSON object into a typed map with [convert].
Map<String, T> jsonMap<T>(Object? value, T Function(Object? item) convert) => {
      for (final entry in asJsonMap(value).entries)
        entry.key: convert(entry.value)
    };
