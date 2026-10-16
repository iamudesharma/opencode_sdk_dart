import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_cockpit/src/markdown_lite.dart';
import 'package:opencode_cockpit/src/theme.dart';

const _markdown = '''
# Release notes

Intro with `code`, **bold**, and *italic* spans.

## Fixes

- streaming transcript scrolls smoothly
- copy button for code

1. first step
2. second step

> Steer with Enter, queue with the button.

---

```dart
final stream = store.watch(sessionID);
```
''';

Future<void> pumpMarkdown(WidgetTester tester, Brightness brightness) {
  return tester.pumpWidget(
    MaterialApp(
      theme: buildCockpitTheme(brightness),
      home: Scaffold(
        body: SingleChildScrollView(child: MarkdownLite(text: _markdown)),
      ),
    ),
  );
}

void main() {
  testWidgets('renders headings, lists, quotes, rules, and code blocks', (
    tester,
  ) async {
    await pumpMarkdown(tester, Brightness.light);

    expect(find.text('Release notes'), findsOneWidget);
    expect(find.text('Fixes'), findsOneWidget);
    expect(find.text('•'), findsNWidgets(2));
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(find.textContaining('Steer with Enter'), findsOneWidget);
    expect(find.text('DART'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.textContaining('store.watch'), findsOneWidget);
  });

  testWidgets('copy button swaps to a confirmation and back', (tester) async {
    await pumpMarkdown(tester, Brightness.dark);

    await tester.tap(find.text('Copy'));
    await tester.pump();
    expect(find.text('Copied'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('code blocks use theme-aware colors', (tester) async {
    await pumpMarkdown(tester, Brightness.light);
    final theme = buildCockpitTheme(Brightness.light);
    final container = tester.widgetList<Container>(find.byType(Container));
    expect(
      container.any((widget) {
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.color == theme.codeBackground;
      }),
      isTrue,
    );
  });
}
