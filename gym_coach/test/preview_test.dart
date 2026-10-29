import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_coach/main.dart' show openFitTheme;
import 'package:gym_coach/src/home_screen.dart';
import 'package:gym_coach/src/plan_store.dart';

import 'home_screen_test.dart' show FakeCoachService;

final _previewKey = GlobalKey();

Future<void> _loadFonts() async {
  Future<void> load(String family, String asset) async {
    final loader = FontLoader(family)..addFont(rootBundle.load(asset));
    await loader.load();
  }

  await load('InstrumentSans', 'assets/fonts/InstrumentSans.ttf');
  await load('Fraunces', 'assets/fonts/Fraunces.ttf');
  await load('JetBrainsMono', 'assets/fonts/JetBrainsMono.ttf');
  await load(
    'MaterialIcons',
    '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/'
        'material_fonts/MaterialIcons-Regular.otf',
  );
}

Future<Directory> _pump(
  WidgetTester tester, {
  Size size = const Size(1400, 1000),
  bool generate = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final temp = Directory.systemTemp.createTempSync('openfit_preview');
  addTearDown(() {
    if (temp.existsSync()) temp.deleteSync(recursive: true);
  });
  await tester.pumpWidget(
    RepaintBoundary(
      key: _previewKey,
      child: MaterialApp(
        theme: openFitTheme(),
        debugShowCheckedModeBanner: false,
        home: HomeScreen(
          service: FakeCoachService(),
          store: PlanStore(directory: temp.path),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (generate) {
    await tester.tap(find.text('Generate plan'));
    await tester.pumpAndSettle();
  }
  return temp;
}

Future<void> _capture(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_previewKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1.25);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('test/previews')..createSync(recursive: true);
    File('${directory.path}/$name.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  testWidgets('openfit empty desktop', (tester) async {
    await _pump(tester);
    await _capture(tester, 'openfit_empty');
  });

  testWidgets('openfit typed plan', (tester) async {
    await _pump(tester, generate: true);
    await _capture(tester, 'openfit_plan');
  });

  testWidgets('openfit plan scrolled', (tester) async {
    await _pump(tester, generate: true);
    await tester.scrollUntilVisible(
      find.text('Breakfast'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await _capture(tester, 'openfit_food');
  });

  testWidgets('openfit coach dock', (tester) async {
    await _pump(tester, generate: true);
    await tester.tap(find.text('Ask Coach'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('coach_input')),
      'My knee hurts after squats',
    );
    await tester.tap(find.byKey(const ValueKey('coach_send')));
    await tester.pumpAndSettle();
    await _capture(tester, 'openfit_coach');
  });

  testWidgets('openfit narrow build', (tester) async {
    await _pump(tester, size: const Size(390, 844));
    await _capture(tester, 'openfit_narrow');
  });
}
