import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_coach/src/plan_store.dart';

void main() {
  late Directory temp;
  late PlanStore store;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('gym_coach_store_test');
    store = PlanStore(directory: temp.path);
  });

  tearDown(() {
    if (temp.existsSync()) temp.deleteSync(recursive: true);
  });

  SavedPlan plan({
    required String id,
    DateTime? createdAt,
    Map<String, dynamic>? structured,
    String? rawText,
  }) => SavedPlan(
    id: id,
    createdAt: createdAt ?? DateTime(2026, 10, 16, 12),
    modelId: 'longcat-2.5-preview-free',
    title: 'Build muscle · 4 days · LongCat',
    markdown: '# Training plan',
    structured: structured,
    rawText: rawText,
  );

  test('lists an empty store', () async {
    expect(await store.list(), isEmpty);
  });

  test('saves and lists plans newest first', () async {
    await store.save(plan(id: 'plan-1', createdAt: DateTime(2026, 10, 15)));
    await store.save(plan(id: 'plan-2', createdAt: DateTime(2026, 10, 16)));

    final plans = await store.list();
    expect(plans.map((p) => p.id), ['plan-2', 'plan-1']);
    expect(plans.first.title, 'Build muscle · 4 days · LongCat');
  });

  test('round-trips a structured plan', () async {
    await store.save(
      plan(
        id: 'plan-typed',
        structured: {
          'overview': 'A 3-day plan.',
          'days': [
            {
              'name': 'Day 1 — Full body',
              'focus': 'Squat focus',
              'exercises': [
                {'name': 'Goblet squat', 'prescription': '3 x 8-12'},
              ],
            },
          ],
          'progression': 'Add 2.5 kg per week.',
        },
      ),
    );

    final saved = (await store.list()).single;
    expect(saved.structured, isNotNull);
    expect(saved.structured!['overview'], 'A 3-day plan.');
    expect(saved.rawText, isNull);
  });

  test('round-trips a text plan', () async {
    await store.save(plan(id: 'plan-text', rawText: 'PLAN OVERVIEW\nHello.'));
    final saved = (await store.list()).single;
    expect(saved.rawText, 'PLAN OVERVIEW\nHello.');
    expect(saved.structured, isNull);
  });

  test('deletes a plan', () async {
    await store.save(plan(id: 'plan-1'));
    await store.delete('plan-1');
    expect(await store.list(), isEmpty);
    // Deleting a missing plan is a no-op.
    await store.delete('plan-1');
  });

  test('skips unreadable files', () async {
    await store.save(plan(id: 'plan-1'));
    File('${temp.path}/broken.json').writeAsStringSync('not json');
    final plans = await store.list();
    expect(plans.map((p) => p.id), ['plan-1']);
  });
}
