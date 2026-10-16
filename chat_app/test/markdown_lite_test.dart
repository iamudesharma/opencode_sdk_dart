import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_chat/src/copy_button.dart';
import 'package:opencode_chat/src/markdown_lite.dart';

void main() {
  group('parseMarkdownLite', () {
    test('parses headings with their levels', () {
      final blocks = parseMarkdownLite(
        '# Title\n\n## Section\n\n### Detail\n\n###### Deep\n',
      );
      expect(blocks, hasLength(4));
      expect(
        blocks.map((block) => (block as MarkdownHeading).level),
        [1, 2, 3, 6],
      );
      expect(
        blocks.map((block) => (block as MarkdownHeading).text),
        ['Title', 'Section', 'Detail', 'Deep'],
      );
    });

    test('parses paragraphs and horizontal rules', () {
      final blocks = parseMarkdownLite('first line\nsecond line\n\n---\n');
      expect(blocks, hasLength(2));
      expect(blocks[0], isA<MarkdownParagraph>());
      expect((blocks[0] as MarkdownParagraph).text, 'first line\nsecond line\n');
      expect(blocks[1], isA<MarkdownRule>());
    });

    test('parses bullet and ordered lists', () {
      final blocks = parseMarkdownLite(
        '- one\n* two\n\n1. first\n2. second\n',
      );
      expect(blocks, hasLength(2));
      final bullets = blocks[0] as MarkdownListBlock;
      expect(bullets.ordered, isFalse);
      expect(bullets.items.map((item) => item.text), ['one', 'two']);
      final ordered = blocks[1] as MarkdownListBlock;
      expect(ordered.ordered, isTrue);
      expect(ordered.items.map((item) => item.text), ['first', 'second']);
    });

    test('parses blockquotes across lines', () {
      final blocks = parseMarkdownLite('> quoted\n> continued\n\nplain');
      expect(blocks, hasLength(2));
      expect((blocks[0] as MarkdownQuote).text, 'quoted\ncontinued');
      expect(blocks[1], isA<MarkdownParagraph>());
    });

    test('parses fenced code blocks with a language', () {
      final blocks = parseMarkdownLite(
        'before\n\n```dart\nfinal x = 1;\n```\n\nafter',
      );
      expect(blocks, hasLength(3));
      final code = blocks[1] as MarkdownCode;
      expect(code.language, 'dart');
      expect(code.code, 'final x = 1;\n');
      expect(blocks[2], isA<MarkdownParagraph>());
    });

    test('keeps an unterminated fence as a code block', () {
      final blocks = parseMarkdownLite('```\nno closing fence');
      expect(blocks, hasLength(1));
      expect(blocks.single, isA<MarkdownCode>());
      expect((blocks.single as MarkdownCode).language, isNull);
    });

    test('does not treat inline emphasis as a list', () {
      final blocks = parseMarkdownLite('*italic* text\n\n- bullet');
      expect(blocks, hasLength(2));
      expect(blocks[0], isA<MarkdownParagraph>());
      expect(blocks[1], isA<MarkdownListBlock>());
    });
  });

  group('MarkdownLite', () {
    Future<void> pumpMarkdown(WidgetTester tester, String text) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MarkdownLite(text: text),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    SelectableText selectableWith(WidgetTester tester, String text) {
      return tester
          .widgetList<SelectableText>(find.byType(SelectableText))
          .firstWhere(
            (widget) =>
                (widget.textSpan ?? TextSpan(text: widget.data))
                    .toPlainText() ==
                text,
          );
    }

    testWidgets('renders headings larger and bolder than body text',
        (tester) async {
      await pumpMarkdown(tester, '# Big heading\n\nbody text');
      final heading = selectableWith(tester, 'Big heading');
      final body = selectableWith(tester, 'body text');
      expect(heading.style!.fontSize!, greaterThan(body.style!.fontSize!));
      expect(heading.style!.fontWeight, FontWeight.w700);
    });

    testWidgets('renders lists with bullets and numbers', (tester) async {
      await pumpMarkdown(tester, '- alpha\n- beta\n\n1. one\n2. two');
      expect(selectableWith(tester, 'alpha'), isNotNull);
      expect(selectableWith(tester, 'beta'), isNotNull);
      expect(selectableWith(tester, 'one'), isNotNull);
      expect(selectableWith(tester, 'two'), isNotNull);
      expect(find.text('\u2022'), findsNWidgets(2));
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
    });

    testWidgets('renders blockquotes and rules', (tester) async {
      await pumpMarkdown(tester, '> quoted text\n\n---\n\nafter');
      expect(selectableWith(tester, 'quoted text'), isNotNull);
      expect(selectableWith(tester, 'after'), isNotNull);
    });

    testWidgets('renders code blocks with a badge and a copy button',
        (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => null,
      );
      await pumpMarkdown(tester, '```dart\nprint(1);\n```');
      expect(find.text('dart'), findsOneWidget);
      expect(find.text('print(1);'), findsOneWidget);
      expect(find.byType(CopyButton), findsOneWidget);
      await tester.tap(find.byType(CopyButton));
      await tester.pump();
      await tester.pump();
      expect(find.text('Copied'), findsOneWidget);
    });

    testWidgets('styles inline code, bold, and italic spans', (tester) async {
      await pumpMarkdown(
        tester,
        'Text with `code`, **bold**, and *italic* words.',
      );
      final rich = selectableWith(tester, 'Text with code, bold, and italic words.');
      final spans = rich.textSpan!.children!.whereType<TextSpan>().toList();
      final code = spans.firstWhere((span) => span.text == 'code');
      final bold = spans.firstWhere((span) => span.text == 'bold');
      final italic = spans.firstWhere((span) => span.text == 'italic');
      expect(code.style!.fontFamily, 'Menlo');
      expect(bold.style!.fontWeight, FontWeight.w600);
      expect(italic.style!.fontStyle, FontStyle.italic);
    });

    testWidgets('appends a streaming caret to the last block', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MarkdownLite(text: 'streaming now', streaming: true),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(selectableWith(tester, 'streaming now\u258C'), isNotNull);
    });
  });
}
