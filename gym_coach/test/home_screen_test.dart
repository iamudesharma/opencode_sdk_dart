import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genkit/genkit.dart';
import 'package:gym_coach/src/coach_service.dart';
import 'package:gym_coach/src/home_screen.dart';
import 'package:gym_coach/src/plan.dart';
import 'package:gym_coach/src/plan_request.dart';
import 'package:gym_coach/src/plan_store.dart';
import 'package:gym_coach/main.dart' show openFitTheme;
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart'
    show PromptInputFileAttachment;

/// A plan fixture with one day, one meal and a safety note.
WorkoutPlan fixturePlan() => WorkoutPlan(
  overview: 'A 3-day full-body plan with dumbbells.',
  days: [
    TrainingDay(
      name: 'Day 1 — Full body',
      focus: 'Squat focus, 45 minutes',
      warmup: '5 min bike, leg swings',
      exercises: [
        Exercise(
          name: 'Goblet squat',
          prescription: '3 x 8-12, rest 90s',
          notes: 'Knee-friendly depth.',
        ),
        Exercise(name: 'Floor press', prescription: '3 x 10, rest 75s'),
      ],
      cooldown: 'Hamstring and hip stretch',
    ),
  ],
  progression: 'Add 2.5 kg when all sets hit the top of the rep range.',
  meals: [
    FoodMeal(
      meal: 'Breakfast',
      items: ['Oats 80 g', 'Whey 30 g', 'Berries 100 g'],
      calories: 600,
      proteinG: 45,
    ),
  ],
  safetyNotes: 'Stop if the left knee hurts.',
);

/// A service that answers from fixtures instead of the OpenCode server.
final class FakeCoachService extends CoachService {
  FakeCoachService({
    this.failCatalog = false,
    this.failTyped = false,
    this.chatDelay = const Duration(milliseconds: 20),
  });

  final bool failCatalog;
  final bool failTyped;
  final Duration chatDelay;
  final generated = <PlanRequest>[];
  final typedRequests = <PlanRequest>[];
  final chatRequests = <String>[];
  final chatAttachments = <List<PromptInputFileAttachment>?>[];
  var cancelled = false;

  @override
  void cancel() => cancelled = true;

  @override
  Future<List<CoachModel>> listModels() async {
    if (failCatalog) throw StateError('no server');
    return const [
      CoachModel(id: kPreferredModelId, label: 'LongCat 2.5 Preview Free'),
      CoachModel(id: 'some-paid-model', label: 'Some Paid Model'),
    ];
  }

  @override
  Future<TypedPlanResult> generateTypedPlan({
    required String modelId,
    required PlanRequest request,
    List<PromptInputFileAttachment>? attachments,
    void Function(int receivedCharacters)? onProgress,
  }) async {
    typedRequests.add(request);
    if (failTyped) {
      throw GenkitException(
        'The model answered with text that did not match the plan schema.',
      );
    }
    onProgress?.call(512);
    return TypedPlanResult(
      plan: fixturePlan(),
      usage: GenerationUsage(totalTokens: 128),
      latencyMs: 12,
    );
  }

  @override
  Stream<PlanEvent> generatePlan({
    required String modelId,
    required PlanRequest request,
    List<PromptInputFileAttachment>? attachments,
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

  @override
  Stream<CoachChatEvent> askCoach({
    required String text,
    List<PromptInputFileAttachment>? attachments,
  }) async* {
    chatRequests.add(text);
    chatAttachments.add(attachments);
    yield const CoachChatDelta('Try ');
    await Future<void>.delayed(chatDelay);
    if (cancelled) {
      yield const CoachChatDone('', cancelled: true);
      return;
    }
    yield const CoachChatDelta('rest 60s ');
    yield const CoachChatDelta('between sets.');
    yield CoachChatDone(
      'Try rest 60s between sets.',
      usage: GenerationUsage(totalTokens: 12),
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

  /// The phone viewport the responsive shell targets.
  void useNarrowViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  late Directory temp;
  late PlanStore store;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('gym_coach_widget_test');
    store = PlanStore(directory: temp.path);
  });

  tearDown(() {
    if (temp.existsSync()) temp.deleteSync(recursive: true);
  });

  Future<void> pumpApp(WidgetTester tester, CoachService service) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: openFitTheme(),
        home: HomeScreen(service: service, store: store),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> generateTyped(WidgetTester tester) async {
    await tester.tap(find.text('Generate plan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Finder navDestination(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('generates a typed plan and renders day tabs and meals', (
    tester,
  ) async {
    useDesktopViewport(tester);
    final service = FakeCoachService();
    await pumpApp(tester, service);

    // Typed mode is the default.
    expect(find.text('Typed plan'), findsOneWidget);

    await generateTyped(tester);

    expect(service.typedRequests, hasLength(1));
    expect(service.generated, isEmpty);
    // The prompt asked for the structured shape.
    expect(service.typedRequests.single.nutritionTargets, isNull);

    expect(find.text('Day 1 — Full body'), findsOneWidget);
    expect(find.text('Goblet squat'), findsOneWidget);
    expect(find.text('3 x 8-12, rest 90s'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('600 kcal'), findsOneWidget);
    expect(find.textContaining('128 tokens'), findsOneWidget);
  });

  testWidgets('live text mode streams the plan as before', (tester) async {
    useDesktopViewport(tester);
    final service = FakeCoachService();
    await pumpApp(tester, service);

    await tester.tap(find.text('Live text'));
    await tester.pump();
    await tester.tap(find.text('Generate plan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(service.generated, hasLength(1));
    expect(service.typedRequests, isEmpty);
    expect(find.textContaining('full-body plan with dumbbells'), findsWidgets);
    expect(find.textContaining('42 tokens'), findsOneWidget);
  });

  testWidgets('preset cards fill the form and generate', (tester) async {
    useDesktopViewport(tester);
    final service = FakeCoachService();
    await pumpApp(tester, service);

    await tester.tap(find.text('Hotel room week'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(service.typedRequests, hasLength(1));
    final request = service.typedRequests.single;
    expect(request.equipment, GymEquipment.bodyweight);
    expect(request.sessionMinutes, 30);
  });

  testWidgets('macro calculator computes targets and applies them', (
    tester,
  ) async {
    useDesktopViewport(tester);
    final service = FakeCoachService();
    await pumpApp(tester, service);

    // Defaults: 80 kg, 178 cm, 30 y, male, moderate, maintain.
    await tester.scrollUntilVisible(
      find.text('Use in plan'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Use in plan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('kcal'), findsWidgets);
    await tester.tap(find.text('Use in plan'), warnIfMissed: true);
    await tester.pump();

    await generateTyped(tester);

    final request = service.typedRequests.single;
    expect(request.nutritionTargets, isNotNull);
    expect(request.nutritionTargets, contains('kcal/day'));
    expect(request.nutritionTargets, contains('g protein'));
    // The structured prompt carries the targets.
    expect(request.toPrompt(structured: true), contains('calculator'));
  });

  testWidgets('typed mode failure suggests live text', (tester) async {
    useDesktopViewport(tester);
    final service = FakeCoachService(failTyped: true);
    await pumpApp(tester, service);

    await generateTyped(tester);

    expect(find.text('Generation failed'), findsOneWidget);
    expect(
      find.textContaining('did not match the plan schema'),
      findsOneWidget,
    );
  });

  testWidgets('history dialog lists and loads saved plans', (tester) async {
    useDesktopViewport(tester);
    // Seed the store with one saved plan.
    File('${temp.path}/plan-seed.json').writeAsStringSync(
      jsonEncode({
        'id': 'plan-seed',
        'createdAt': DateTime(2026, 10, 16, 9).toIso8601String(),
        'modelId': kPreferredModelId,
        'title': 'Lose fat · 4 days · LongCat 2.5 Preview Free',
        'markdown': '# Training plan\nSeed.',
        'rawText': 'PLAN OVERVIEW\nSeed plan text.',
      }),
    );

    final service = FakeCoachService();
    await pumpApp(tester, service);

    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    expect(find.text('Plan history'), findsOneWidget);
    expect(
      find.text('Lose fat · 4 days · LongCat 2.5 Preview Free'),
      findsOneWidget,
    );

    await tester.tap(
      find.text('Lose fat · 4 days · LongCat 2.5 Preview Free'),
    );
    await tester.pumpAndSettle();

    // The saved text plan is rendered in live-text mode.
    expect(find.textContaining('Seed plan text'), findsOneWidget);
    expect(service.generated, isEmpty);
    expect(service.typedRequests, isEmpty);
  });

  testWidgets('shows a retry path when the server is unreachable', (
    tester,
  ) async {
    useDesktopViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: openFitTheme(),
        home: HomeScreen(
          service: FakeCoachService(failCatalog: true),
          store: store,
        ),
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

  testWidgets('narrow layout renders the navigation bar and switches tabs', (
    tester,
  ) async {
    useNarrowViewport(tester);
    final service = FakeCoachService();
    await pumpApp(tester, service);

    expect(find.byType(NavigationBar), findsOneWidget);
    IndexedStack tabs() =>
        tester.widget<IndexedStack>(find.byKey(const ValueKey('tabs')));
    expect(tabs().index, 0);

    await tester.tap(navDestination('Workout'));
    await tester.pumpAndSettle();
    expect(tabs().index, 1);

    await tester.tap(navDestination('Coach'));
    await tester.pumpAndSettle();
    expect(tabs().index, 2);

    await tester.tap(navDestination('History'));
    await tester.pumpAndSettle();
    expect(tabs().index, 3);
  });

  testWidgets('exercise toggle updates the day progress', (tester) async {
    useDesktopViewport(tester);
    final service = FakeCoachService();
    await pumpApp(tester, service);

    await generateTyped(tester);

    expect(find.text('0/2 done'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.text('1/2 done'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.text('0/2 done'), findsOneWidget);
  });

  testWidgets('rest timer starts and counts down in the day header', (
    tester,
  ) async {
    useDesktopViewport(tester);
    final service = FakeCoachService();
    await pumpApp(tester, service);

    await generateTyped(tester);

    await tester.tap(find.byTooltip('Rest timer').first);
    await tester.pump();
    // The fixture prescription says `rest 90s`.
    expect(find.text('01:30'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('01:29'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('01:28'), findsOneWidget);

    await tester.tap(find.byTooltip('Stop rest timer'));
    await tester.pump();
    expect(find.text('01:28'), findsNothing);
  });

  testWidgets('macro bars compare the food plan with applied targets', (
    tester,
  ) async {
    useDesktopViewport(tester);
    final service = FakeCoachService();
    await pumpApp(tester, service);

    await tester.scrollUntilVisible(
      find.text('Use in plan'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Use in plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use in plan'), warnIfMissed: true);
    await tester.pump();

    await generateTyped(tester);

    expect(find.text('TARGETS VS PLAN'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.textContaining('/ 2740 kcal'), findsOneWidget);
    expect(find.text('Protein'), findsOneWidget);
    expect(find.textContaining('/ 144 g'), findsOneWidget);
  });

  testWidgets('ask coach streams bubbles and rebuilds with the note', (
    tester,
  ) async {
    useNarrowViewport(tester);
    final service = FakeCoachService();
    await pumpApp(tester, service);

    await tester.tap(navDestination('Coach'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('coach_input')),
      'My knee hurts after squats',
    );
    await tester.tap(find.byKey(const ValueKey('coach_send')));
    await tester.pump();
    expect(find.text('My knee hurts after squats'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('rest 60s between sets'), findsOneWidget);

    await tester.tap(find.text('Rebuild plan with this note'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(service.typedRequests, hasLength(1));
    expect(
      service.typedRequests.single.notes,
      contains('rest 60s between sets'),
    );
  });

  testWidgets('ask coach stop cancels the in-flight turn', (tester) async {
    useNarrowViewport(tester);
    final service = FakeCoachService(
      chatDelay: const Duration(milliseconds: 300),
    );
    await pumpApp(tester, service);

    await tester.tap(navDestination('Coach'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('coach_input')), 'hello');
    await tester.tap(find.byKey(const ValueKey('coach_send')));
    await tester.pump();

    expect(find.byKey(const ValueKey('coach_stop')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('coach_stop')));
    await tester.pump();
    expect(service.cancelled, isTrue);

    // The fake finishes the cancelled turn; Send comes back.
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('coach_send')), findsOneWidget);
  });

  testWidgets('history tab lists and loads a seeded plan', (tester) async {
    useNarrowViewport(tester);
    File('${temp.path}/plan-seed.json').writeAsStringSync(
      jsonEncode({
        'id': 'plan-seed',
        'createdAt': DateTime(2026, 10, 16, 9).toIso8601String(),
        'modelId': kPreferredModelId,
        'title': 'Lose fat · 4 days · LongCat 2.5 Preview Free',
        'markdown': '# Training plan\nSeed.',
        'rawText': 'PLAN OVERVIEW\nSeed plan text.',
      }),
    );

    final service = FakeCoachService();
    await pumpApp(tester, service);

    await tester.tap(navDestination('History'));
    await tester.pumpAndSettle();

    expect(
      find.text('Lose fat · 4 days · LongCat 2.5 Preview Free'),
      findsOneWidget,
    );

    await tester.tap(
      find.text('Lose fat · 4 days · LongCat 2.5 Preview Free'),
    );
    await tester.pumpAndSettle();

    // Loading switches to the Workout tab with the saved text.
    final tabs = tester.widget<IndexedStack>(
      find.byKey(const ValueKey('tabs')),
    );
    expect(tabs.index, 1);
    expect(find.textContaining('Seed plan text'), findsOneWidget);
  });
}
