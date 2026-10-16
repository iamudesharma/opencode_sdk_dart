/// `dart:io` plan storage: one JSON file per plan.
library;

import 'dart:convert';
import 'dart:io';

import 'plan_store.dart';

/// Stores generated plans as JSON files under a directory.
final class IoPlanStoreBackend implements PlanStoreBackend {
  /// Creates a file-backed store rooted at [directory].
  IoPlanStoreBackend(this._directory);

  final String _directory;

  @override
  String get directory => _directory;

  @override
  Future<List<SavedPlan>> list() async {
    final dir = Directory(_directory);
    if (!dir.existsSync()) return const [];
    final plans = <SavedPlan>[];
    for (final entity in dir.listSync()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      try {
        final decoded = jsonDecode(entity.readAsStringSync());
        if (decoded is Map<String, dynamic>) {
          plans.add(SavedPlan.fromJson(decoded));
        }
      } on Object {
        // Skip unreadable entries; history is best-effort.
      }
    }
    plans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return plans;
  }

  @override
  Future<void> save(SavedPlan plan) async {
    final dir = Directory(_directory);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    await File('$_directory/${plan.id}.json').writeAsString(
      jsonEncode(plan.toJson()),
    );
  }

  @override
  Future<void> delete(String id) async {
    final file = File('$_directory/$id.json');
    if (file.existsSync()) {
      await file.delete();
    }
  }
}

/// Creates the `dart:io` backend.
PlanStoreBackend createPlanStoreBackend(String? directory) =>
    IoPlanStoreBackend(directory ?? platformDefaultDirectory());

/// The default storage directory: `~/Library/Application Support/gym_coach/plans`.
String platformDefaultDirectory() {
  final home = Platform.environment['HOME'] ?? Directory.systemTemp.path;
  return '$home/Library/Application Support/gym_coach/plans';
}
