/// Fallback plan storage for platforms with neither files nor `localStorage`.
library;

import 'plan_store.dart';

/// Keeps plans in memory for the session.
final class MemoryPlanStoreBackend implements PlanStoreBackend {
  /// Creates an in-memory store.
  MemoryPlanStoreBackend([String? directory])
    : _directory = directory ?? 'memory://gym_coach_plans';

  final String _directory;
  final List<SavedPlan> _plans = <SavedPlan>[];

  @override
  String get directory => _directory;

  @override
  Future<List<SavedPlan>> list() async {
    final plans = List<SavedPlan>.of(_plans)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return plans;
  }

  @override
  Future<void> save(SavedPlan plan) async {
    _plans.removeWhere((existing) => existing.id == plan.id);
    _plans.add(plan);
  }

  @override
  Future<void> delete(String id) async {
    _plans.removeWhere((existing) => existing.id == id);
  }
}

/// Creates the in-memory backend.
PlanStoreBackend createPlanStoreBackend(String? directory) =>
    MemoryPlanStoreBackend(directory);

/// The virtual directory label shown for the in-memory list.
String platformDefaultDirectory() => 'memory://gym_coach_plans';
