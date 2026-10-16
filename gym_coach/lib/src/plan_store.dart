/// Local persistence for generated plans.
///
/// The public API is identical on every platform; the storage behind it is
/// chosen at compile time: one JSON file per plan under the app support
/// directory on desktop, one JSON array in `window.localStorage` on the web.
/// The store never throws for a missing directory, an unreadable entry, or a
/// failed write; history is a convenience, not a source of truth.
library;

import 'plan_store_stub.dart'
    if (dart.library.io) 'plan_store_io.dart'
    if (dart.library.js_interop) 'plan_store_web.dart';

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

/// The platform-specific storage behind [PlanStore].
abstract interface class PlanStoreBackend {
  /// The storage location shown to the user.
  String get directory;

  /// Lists stored plans, newest first.
  Future<List<SavedPlan>> list();

  /// Writes [plan] to the store, replacing any entry with the same id.
  Future<void> save(SavedPlan plan);

  /// Deletes the plan with [id], when it exists.
  Future<void> delete(String id);
}

/// Stores generated plans on the platform's natural medium.
final class PlanStore {
  /// Creates a store rooted at [directory], or at the platform default.
  ///
  /// The directory argument is only meaningful on desktop; the web backend
  /// keeps its plans in `window.localStorage` and ignores it.
  PlanStore({String? directory}) : _backend = createPlanStoreBackend(directory);

  final PlanStoreBackend _backend;

  /// The default storage directory (a virtual key on the web).
  static String defaultDirectory() => platformDefaultDirectory();

  /// The storage directory path.
  String get directory => _backend.directory;

  /// Lists stored plans, newest first.
  Future<List<SavedPlan>> list() => _backend.list();

  /// Writes [plan] to the store, replacing any file with the same id.
  Future<void> save(SavedPlan plan) => _backend.save(plan);

  /// Deletes the plan with [id], when it exists.
  Future<void> delete(String id) => _backend.delete(id);
}
