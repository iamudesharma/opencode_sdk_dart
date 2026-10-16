/// Local persistence for generated plans.
///
/// Each plan is one JSON file under the app support directory, so history
/// survives restarts without a database. The store never throws for a missing
/// directory, an unreadable file, or a failed write of one entry; history is a
/// convenience, not a source of truth.
library;

import 'dart:convert';
import 'dart:io';

/// One saved plan.
final class SavedPlan {
  /// Creates a saved plan.
  const SavedPlan({
    required this.id,
    required this.createdAt,
    required this.modelId,
    required this.title,
    required this.markdown,
    this.structured,
    this.rawText,
  });

  /// Decodes a stored plan.
  factory SavedPlan.fromJson(Map<String, dynamic> json) => SavedPlan(
    id: json['id'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    modelId: json['modelId'] as String? ?? '',
    title: json['title'] as String? ?? 'Plan',
    markdown: json['markdown'] as String? ?? '',
    structured: (json['structured'] as Map?)?.cast<String, dynamic>(),
    rawText: json['rawText'] as String?,
  );

  /// File-name-safe identifier.
  final String id;

  /// When the plan was generated.
  final DateTime createdAt;

  /// The model that produced it.
  final String modelId;

  /// Human-readable title, e.g. `'Build muscle · 4 days · LongCat'`.
  final String title;

  /// Markdown rendering (used for copy and export).
  final String markdown;

  /// The typed plan's JSON, when the plan was generated in typed mode.
  final Map<String, dynamic>? structured;

  /// The streamed text, when the plan was generated in live-text mode.
  final String? rawText;

  /// Encodes the plan for storage.
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'modelId': modelId,
    'title': title,
    'markdown': markdown,
    if (structured != null) 'structured': structured,
    if (rawText != null) 'rawText': rawText,
  };
}

/// Stores generated plans as JSON files.
final class PlanStore {
  /// Creates a store rooted at [directory], or at the app support directory.
  PlanStore({String? directory}) : _directory = directory ?? defaultDirectory();

  final String _directory;

  /// The default storage directory: `~/Library/Application Support/gym_coach/plans`.
  static String defaultDirectory() {
    final home = Platform.environment['HOME'] ?? Directory.systemTemp.path;
    return '$home/Library/Application Support/gym_coach/plans';
  }

  /// The storage directory path.
  String get directory => _directory;

  /// Lists stored plans, newest first.
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

  /// Writes [plan] to the store, replacing any file with the same id.
  Future<void> save(SavedPlan plan) async {
    final dir = Directory(_directory);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    await File('$_directory/${plan.id}.json').writeAsString(
      jsonEncode(plan.toJson()),
    );
  }

  /// Deletes the plan with [id], when it exists.
  Future<void> delete(String id) async {
    final file = File('$_directory/$id.json');
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
