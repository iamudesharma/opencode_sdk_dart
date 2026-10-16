/// Web plan storage: a JSON array in `window.localStorage`.
library;

import 'dart:convert';

import 'package:web/web.dart' as web;

import 'plan_store.dart';

/// The `localStorage` key holding every saved plan as one JSON array.
const String _storageKey = 'gym_coach_plans';

/// Stores generated plans as one JSON array in `window.localStorage`.
final class WebPlanStoreBackend implements PlanStoreBackend {
  /// Creates a store; [directory] is a display-only label on the web.
  WebPlanStoreBackend(this._directory);

  final String _directory;

  @override
  String get directory => _directory;

  List<SavedPlan> _read() {
    final raw = web.window.localStorage.getItem(_storageKey);
    if (raw == null || raw.isEmpty) return <SavedPlan>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <SavedPlan>[];
      return [
        for (final entry in decoded)
          if (entry is Map) SavedPlan.fromJson(entry.cast<String, dynamic>()),
      ];
    } on Object {
      // Corrupt storage is treated as empty; history is best-effort.
      return <SavedPlan>[];
    }
  }

  void _write(List<SavedPlan> plans) {
    try {
      web.window.localStorage.setItem(
        _storageKey,
        jsonEncode([for (final plan in plans) plan.toJson()]),
      );
    } on Object {
      // A full or blocked localStorage must not break the app.
    }
  }

  @override
  Future<List<SavedPlan>> list() async {
    final plans = _read()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return plans;
  }

  @override
  Future<void> save(SavedPlan plan) async {
    final plans = _read()..removeWhere((existing) => existing.id == plan.id);
    plans.add(plan);
    _write(plans);
  }

  @override
  Future<void> delete(String id) async {
    final plans = _read()..removeWhere((existing) => existing.id == id);
    _write(plans);
  }
}

/// Creates the `window.localStorage` backend.
PlanStoreBackend createPlanStoreBackend(String? directory) =>
    WebPlanStoreBackend(directory ?? platformDefaultDirectory());

/// The virtual directory label shown for the `localStorage` array.
String platformDefaultDirectory() => 'localStorage://$_storageKey';
