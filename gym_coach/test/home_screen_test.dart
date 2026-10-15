import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genkit/genkit.dart';
import 'package:gym_coach/src/coach_service.dart';
import 'package:gym_coach/src/home_screen.dart';
import 'package:gym_coach/src/plan_request.dart';
import 'package:gym_coach/main.dart' show gymCoachTheme;

/// A service that answers from fixtures instead of the OpenCode server.
final class FakeCoachService extends CoachService {
  FakeCoachService({this.failCatalog = false});

  final bool failCatalog;
  final generated = <PlanRequest>[];
  var cancelled = false;

  @override
  Future<List<CoachModel>> listModels() async {
    if (failCatalog) throw StateError('no server');
    return const [
      CoachModel(id: kPreferredModelId, label: 'LongCat 2.5 Preview Free'),
      CoachModel(id: 'some-paid-model', label: 'Some Paid Model'),
    ];
  }

  @override
  Stream<PlanEvent> generatePlan({
    required String modelId,
    required PlanRequest request,
  }) async* {
    generated.add(request);
    yield const PlanText('PLAN OVERVIEW\n');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    yield const PlanText('3-day full-body plan with dumbbells.');
    yield PlanCompleted(
      text: 'PLAN OVERVIEW\n3-day full-body plan with dumbbells.',
      cancelled: cancelled,
      usage: GenerationUsage(totalTokens: 42),
    );
  }
}

void main() {
  /// Gives tests the same room the real window has, so the whole form is
  /// laid out (list views do not build off-screen children).
  void useDesktopViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('renders the form and streams a generated plan', (
    tester,
  ) async {
    useDesktopViewport(tester);
    final service = FakeCoachService();
    await tester.pumpWidget(
      MaterialApp(theme: gymCoachTheme(), home: HomeScreen(service: service)),
    );
    await tester.pumpAndSettle();

    // The preferred model was selected from the catalog.
    expect(find.textContaining('LongCat'), findsWidgets);

    await tester.tap(find.text('Generate plan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(service.generated, hasLength(1));
    expect(find.textContaining('full-body plan with dumbbells'), findsWidgets);
    expect(find.textContaining('42 tokens'), findsOneWidget);
  });

  testWidgets('preset cards fill the form and generate', (tester) async {
    useDesktopViewport(tester);
    final service = FakeCoachService();
    await tester.pumpWidget(
      MaterialApp(theme: gymCoachTheme(), home: HomeScreen(service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hotel room week'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(service.generated, hasLength(1));
    final request = service.generated.single;
    expect(request.equipment, GymEquipment.bodyweight);
    expect(request.sessionMinutes, 30);
  });

  testWidgets('shows a retry path when the server is unreachable', (
    tester,
  ) async {
    useDesktopViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: gymCoachTheme(),
        home: HomeScreen(service: FakeCoachService(failCatalog: true)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('OpenCode server unreachable'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('OpenCode server unreachable'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
